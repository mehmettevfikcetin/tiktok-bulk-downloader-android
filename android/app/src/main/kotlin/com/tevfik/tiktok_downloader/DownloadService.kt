package com.tevfik.tiktok_downloader

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import com.chaquo.python.Python
import org.json.JSONObject
import java.io.File

class DownloadService : Service() {
    companion object {
        const val ACTION_START = "com.tevfik.tiktok_downloader.action.START"
        const val ACTION_CANCEL = "com.tevfik.tiktok_downloader.action.CANCEL"
        const val ACTION_PAUSE = "com.tevfik.tiktok_downloader.action.PAUSE"
        const val EXTRA_VIDEOS_JSON = "videos_json"

        private const val CHANNEL_ID = "tiktok_downloads"
        private const val CHANNEL_NAME = "TikTok Downloads"
        private const val NOTIF_ID = 4711
        private const val TAG = "DownloadService"
        private const val NOTIF_THROTTLE_MS = 500L

        @Volatile
        private var cancelled = false

        @Volatile
        var isRunning: Boolean = false
            private set

        fun requestCancel() {
            cancelled = true
        }

        fun isCancelled(): Boolean = cancelled
    }

    private var workerThread: Thread? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var lastNotifUpdate = 0L
    private var lastTitle: String = ""
    private var lastIndex: Int = 0
    private var lastTotal: Int = 0
    private var lastPercent: Int = 0
    private lateinit var localizedCtx: Context

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        localizedCtx = LocalePrefsBridge.localizedContext(this)
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        Log.i(TAG, "onStartCommand action=$action running=$isRunning")
        if (action == ACTION_CANCEL || action == ACTION_PAUSE) {
            cancelled = true
            Log.i(TAG, "cancel requested via intent")
            return START_NOT_STICKY
        }

        val json = intent?.getStringExtra(EXTRA_VIDEOS_JSON)
        if (json.isNullOrBlank()) {
            Log.w(TAG, "no videos JSON; stopping")
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }

        if (isRunning) {
            Log.w(TAG, "ignoring start while running")
            return START_NOT_STICKY
        }

        cancelled = false
        isRunning = true

        val initialNotif = buildNotification(
            localizedCtx.getString(R.string.notif_preparing),
            0,
            0,
            indeterminate = true
        )
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIF_ID,
                    initialNotif,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
                )
            } else {
                startForeground(NOTIF_ID, initialNotif)
            }
            Log.i(TAG, "startForeground succeeded channel=$CHANNEL_ID notifId=$NOTIF_ID")
        } catch (t: Throwable) {
            Log.e(TAG, "startForeground failed", t)
        }

        acquireWakeLock()

        workerThread = Thread({ runQueue(json) }, "DownloadService-Worker").also {
            it.isDaemon = true
            it.start()
        }

        return START_NOT_STICKY
    }

    private fun runQueue(json: String) {
        var totalForFailure = 0
        try {
            totalForFailure = countVideos(json)
            Log.i(TAG, "runQueue start total=$totalForFailure")
            val cacheDir = File(applicationContext.cacheDir, "downloads").apply { mkdirs() }
            val idsFile = File(applicationContext.filesDir, "downloaded_ids.txt")

            val py = Python.getInstance()
            val module = py.getModule("ytdlp_runner")

            val progressReporter = ServiceProgressReporter { onProgressEvent(it) }
            val queueReporter = ServiceProgressReporter { onProgressEvent(it) }
            val cancelCheck = CancelCheck()
            val storageHelper = FileStorageHelper.PythonBridge(applicationContext)

            // Best-effort: seed ledger from MediaStore so reinstalls don't re-download.
            try {
                val existing = FileStorageHelper.listExistingDownloadedIds(applicationContext)
                if (existing.isNotEmpty() && !idsFile.exists()) {
                    idsFile.parentFile?.mkdirs()
                    idsFile.writeText(existing.joinToString("\n") + "\n")
                }
            } catch (t: Throwable) {
                Log.w(TAG, "ledger seed failed", t)
            }

            // Pass `json` (String) straight through; the Python side parses it.
            module.callAttr(
                "start_queue",
                json,
                cacheDir.absolutePath,
                idsFile.absolutePath,
                progressReporter,
                queueReporter,
                cancelCheck,
                storageHelper
            )
            Log.i(TAG, "runQueue end ok")
        } catch (t: Throwable) {
            Log.e(TAG, "queue run failed", t)
            val trace = t.stackTraceToString().take(800)
            val errorMessage = "${t.message ?: "Queue failed"}\n$trace"
            PythonBridge.emitDownloadEvent(
                mapOf(
                    "videoId" to "",
                    "index" to 0,
                    "total" to totalForFailure,
                    "percent" to 0,
                    "status" to "error",
                    "error" to errorMessage,
                    "title" to ""
                )
            )
            // Always unstick the UI by emitting a queue_finished event.
            PythonBridge.emitDownloadEvent(
                mapOf(
                    "videoId" to "",
                    "index" to totalForFailure,
                    "total" to totalForFailure,
                    "percent" to 100,
                    "status" to "queue_finished",
                    "error" to null,
                    "title" to "",
                    "completed" to 0,
                    "skipped" to 0,
                    "errors" to 1,
                    "cancelled" to 0
                )
            )
        } finally {
            isRunning = false
            cancelled = false
            releaseWakeLock()
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
        }
    }

    private fun countVideos(json: String): Int {
        return try {
            org.json.JSONArray(json).length()
        } catch (_: Throwable) {
            0
        }
    }

    fun onProgressEvent(event: Map<String, Any?>) {
        PythonBridge.emitDownloadEvent(event)

        val status = event["status"] as? String
        val title = (event["title"] as? String) ?: lastTitle
        val index = (event["index"] as? Number)?.toInt() ?: lastIndex
        val total = (event["total"] as? Number)?.toInt() ?: lastTotal
        val percent = (event["percent"] as? Number)?.toInt() ?: lastPercent

        lastTitle = title
        lastIndex = index
        lastTotal = total
        lastPercent = percent

        val now = System.currentTimeMillis()
        val isMilestone = status != null && status != "downloading"
        if (!isMilestone && now - lastNotifUpdate < NOTIF_THROTTLE_MS) return
        lastNotifUpdate = now

        if (status == "queue_finished") {
            val done = (event["completed"] as? Number)?.toInt() ?: 0
            val errors = (event["errors"] as? Number)?.toInt() ?: 0
            val skipped = (event["skipped"] as? Number)?.toInt() ?: 0
            updateNotification(
                localizedCtx.getString(R.string.notif_done, done, skipped, errors),
                percent = 100,
                total = 100,
                indeterminate = false
            )
            return
        }

        val displayTotal = if (total > 0) total else 1
        val displayIndex = (index + 1).coerceAtMost(displayTotal)
        val body = if (title.isNotEmpty()) {
            localizedCtx.getString(
                R.string.notif_downloading_with_title,
                displayIndex,
                displayTotal,
                title
            )
        } else {
            localizedCtx.getString(
                R.string.notif_downloading_no_title,
                displayIndex,
                displayTotal
            )
        }
        updateNotification(body, percent.coerceIn(0, 100), 100, indeterminate = false)
    }

    private fun updateNotification(text: String, percent: Int, total: Int, indeterminate: Boolean) {
        val notif = buildNotification(text, percent, total, indeterminate)
        val mgr = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        mgr.notify(NOTIF_ID, notif)
    }

    private fun buildNotification(
        text: String,
        progress: Int,
        max: Int,
        indeterminate: Boolean
    ): Notification {
        val contentIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val piFlags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val contentPi = PendingIntent.getActivity(this, 0, contentIntent, piFlags)

        val cancelIntent = Intent(this, DownloadService::class.java).apply {
            action = ACTION_CANCEL
        }
        val cancelPi = PendingIntent.getService(this, 1, cancelIntent, piFlags)

        val smallIcon = applicationInfo.icon
            .takeIf { it != 0 }
            ?: android.R.drawable.stat_sys_download
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(localizedCtx.getString(R.string.notif_app_title))
            .setContentText(text)
            .setSmallIcon(smallIcon)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(contentPi)
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                localizedCtx.getString(R.string.notif_cancel),
                cancelPi
            )

        if (max > 0) builder.setProgress(max, progress, indeterminate)
        return builder.build()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val mgr = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (mgr.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = localizedCtx.getString(R.string.notif_channel_desc)
            setShowBadge(false)
        }
        mgr.createNotificationChannel(channel)
    }

    private fun acquireWakeLock() {
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            val lock = pm.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "TikTokDownloader::Queue"
            )
            lock.setReferenceCounted(false)
            lock.acquire(60 * 60 * 1000L /* 1h timeout */)
            wakeLock = lock
        } catch (t: Throwable) {
            Log.w(TAG, "wake lock acquire failed", t)
        }
    }

    private fun releaseWakeLock() {
        try {
            wakeLock?.takeIf { it.isHeld }?.release()
        } catch (t: Throwable) {
            Log.w(TAG, "wake lock release failed", t)
        }
        wakeLock = null
    }

    override fun onDestroy() {
        cancelled = true
        releaseWakeLock()
        super.onDestroy()
    }

    /** Python checks via `cancel_check.is_cancelled()`. */
    class CancelCheck {
        @Suppress("unused")
        fun is_cancelled(): Boolean = isCancelled()
    }

    /**
     * Reporter for the Python side. Python calls `report(jsonPayload)` with a
     * JSON-encoded string — see `_emit` in downloader.py. Chaquopy does not
     * auto-convert Python dicts to java.util.Map for loosely typed params, so
     * a string is the unambiguous wire format.
     */
    class ServiceProgressReporter(private val sink: (Map<String, Any?>) -> Unit) {
        @Suppress("unused")
        fun report(payloadJson: String?) {
            if (payloadJson.isNullOrBlank()) return
            val map = try {
                parseEventJson(payloadJson)
            } catch (t: Throwable) {
                Log.w("DownloadService", "report parse failed: ${t.message}")
                mapOf(
                    "videoId" to "",
                    "index" to 0,
                    "total" to 0,
                    "percent" to 0,
                    "status" to "error",
                    "error" to "Bad event payload: ${t.message}",
                    "title" to ""
                )
            }
            sink(map)
        }

        private fun parseEventJson(payloadJson: String): Map<String, Any?> {
            val obj = JSONObject(payloadJson)
            fun s(key: String): String? =
                if (obj.has(key) && !obj.isNull(key)) obj.optString(key, "") else null
            fun i(key: String): Int? =
                if (obj.has(key) && !obj.isNull(key)) obj.optInt(key, 0) else null

            val out = HashMap<String, Any?>(10)
            out["videoId"] = s("videoId") ?: ""
            out["title"] = s("title") ?: ""
            out["status"] = s("status") ?: "queued"
            out["error"] = s("error")
            out["index"] = i("index") ?: 0
            out["total"] = i("total") ?: 0
            out["percent"] = i("percent") ?: 0
            // queue_finished extras — only present on terminal event.
            i("completed")?.let { out["completed"] = it }
            i("skipped")?.let { out["skipped"] = it }
            i("errors")?.let { out["errors"] = it }
            i("cancelled")?.let { out["cancelled"] = it }
            return out
        }
    }
}
