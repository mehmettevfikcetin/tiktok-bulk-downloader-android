package com.tevfik.tiktok_downloader

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.chaquo.python.PyObject
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.Executors

object PythonBridge {
    private const val CHANNEL = "com.tevfik.tiktok_downloader/python"
    private const val PROGRESS_CHANNEL = "com.tevfik.tiktok_downloader/link_progress"
    private const val DOWNLOAD_PROGRESS_CHANNEL =
        "com.tevfik.tiktok_downloader/download_progress"
    private const val TAG = "PythonBridge"
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    @Volatile
    private var progressSink: EventChannel.EventSink? = null

    @Volatile
    private var downloadProgressSink: EventChannel.EventSink? = null

    private var appContext: Context? = null

    class ProgressReporter {
        fun report(message: String) {
            val sink = progressSink ?: return
            mainHandler.post {
                try {
                    sink.success(message)
                } catch (t: Throwable) {
                    Log.w(TAG, "progress sink failed: ${t.message}")
                }
            }
        }
    }

    fun emitDownloadEvent(event: Map<String, Any?>) {
        val sink = downloadProgressSink ?: return
        mainHandler.post {
            try {
                sink.success(event)
            } catch (t: Throwable) {
                Log.w(TAG, "download sink failed: ${t.message}")
            }
        }
    }

    fun register(flutterEngine: FlutterEngine, context: Context) {
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(context))
        }
        appContext = context.applicationContext

        val nativeLibDir = context.applicationInfo.nativeLibraryDir

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PROGRESS_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    progressSink = events
                }

                override fun onCancel(arguments: Any?) {
                    progressSink = null
                }
            })

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, DOWNLOAD_PROGRESS_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    downloadProgressSink = events
                }

                override fun onCancel(arguments: Any?) {
                    downloadProgressSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getYtdlpVersion" -> runOnExecutor(result) {
                        Python.getInstance()
                            .getModule("ytdlp_runner")
                            .callAttr("get_ytdlp_version")
                            .toString()
                    }
                    "initFfmpeg" -> runOnExecutor(result) {
                        val ffmpegPath = "$nativeLibDir/libffmpeg.so"
                        Log.i(TAG, "initFfmpeg: $ffmpegPath")
                        Python.getInstance()
                            .getModule("ytdlp_runner")
                            .callAttr("set_ffmpeg_location", ffmpegPath)
                            .toString()
                    }
                    "setCookiePath" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error(
                                "BAD_ARGS",
                                "path is required",
                                null
                            )
                        } else {
                            runOnExecutor(result) {
                                Python.getInstance()
                                    .getModule("ytdlp_runner")
                                    .callAttr("set_cookie_path", path)
                                    .toString()
                            }
                        }
                    }
                    "testDownload" -> {
                        val url = call.argument<String>("url")
                        val outputDir = call.argument<String>("outputDir")
                        if (url == null || outputDir == null) {
                            result.error(
                                "BAD_ARGS",
                                "url and outputDir are required",
                                null
                            )
                        } else {
                            runOnExecutor(result) {
                                Python.getInstance()
                                    .getModule("ytdlp_runner")
                                    .callAttr("test_download", url, outputDir)
                                    .toString()
                            }
                        }
                    }
                    "fetchLinks" -> {
                        val url = call.argument<String>("url")
                        if (url == null) {
                            result.error("BAD_ARGS", "url is required", null)
                        } else {
                            runOnExecutor(result) {
                                val reporter = ProgressReporter()
                                val pyResult = Python.getInstance()
                                    .getModule("ytdlp_runner")
                                    .callAttr("fetch_links", url, reporter)
                                convertVideoList(pyResult)
                            }
                        }
                    }
                    "startDownloads" -> {
                        @Suppress("UNCHECKED_CAST")
                        val videos = call.argument<List<Map<String, Any?>>>("videos")
                        if (videos == null || videos.isEmpty()) {
                            result.error("BAD_ARGS", "videos is required", null)
                        } else {
                            try {
                                startDownloadService(context.applicationContext, videos)
                                result.success(null)
                            } catch (t: Throwable) {
                                Log.e(TAG, "startDownloads failed", t)
                                result.error(
                                    "START_FAILED",
                                    t.message ?: "Failed to start service",
                                    t.stackTraceToString()
                                )
                            }
                        }
                    }
                    "cancelDownloads" -> {
                        // Set the cancel flag synchronously first — the worker
                        // thread polls it, no Intent delivery required. Then
                        // best-effort fire an Intent in case the worker is
                        // blocked inside startService re-entry checks.
                        DownloadService.requestCancel()
                        try {
                            val intent = Intent(
                                context.applicationContext,
                                DownloadService::class.java
                            ).apply { action = DownloadService.ACTION_CANCEL }
                            context.applicationContext.startService(intent)
                        } catch (t: Throwable) {
                            Log.w(TAG, "cancel intent failed (flag already set): ${t.message}")
                        }
                        result.success(null)
                    }
                    "pauseDownloads" -> {
                        // Phase 5 treats pause == cancel (queue-level stop).
                        // True pause/resume is Phase 6.
                        DownloadService.requestCancel()
                        try {
                            val intent = Intent(
                                context.applicationContext,
                                DownloadService::class.java
                            ).apply { action = DownloadService.ACTION_PAUSE }
                            context.applicationContext.startService(intent)
                        } catch (t: Throwable) {
                            Log.w(TAG, "pause intent failed (flag already set): ${t.message}")
                        }
                        result.success(null)
                    }
                    "isDownloadServiceRunning" -> {
                        result.success(DownloadService.isRunning)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startDownloadService(ctx: Context, videos: List<Map<String, Any?>>) {
        // Best-effort: clear any stale `isRunning` flag left behind by a
        // previously crashed/killed service before issuing START. Wrapped in
        // try/catch because Android 8+ background-start restrictions can
        // reject a plain startService — in that case the static state was
        // already clean (no live service), so the START below is safe.
        try {
            val resetIntent = Intent(ctx, DownloadService::class.java).apply {
                action = DownloadService.ACTION_RESET
            }
            ctx.startService(resetIntent)
        } catch (t: Throwable) {
            Log.w(TAG, "reset intent failed (state likely already clean): ${t.message}")
        }

        val arr = JSONArray()
        for (v in videos) {
            val obj = JSONObject()
            obj.put("id", v["id"]?.toString().orEmpty())
            obj.put("url", v["url"]?.toString().orEmpty())
            obj.put("title", v["title"]?.toString().orEmpty())
            arr.put(obj)
        }
        val intent = Intent(ctx, DownloadService::class.java).apply {
            action = DownloadService.ACTION_START
            putExtra(DownloadService.EXTRA_VIDEOS_JSON, arr.toString())
        }
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            ctx.startForegroundService(intent)
        } else {
            ctx.startService(intent)
        }
    }

    private fun convertVideoList(pyResult: PyObject): List<Map<String, Any?>> {
        val list = pyResult.asList()
        val out = ArrayList<Map<String, Any?>>(list.size)
        for (item in list) {
            val map = item.asMap()
            val converted = HashMap<String, Any?>(map.size)
            for ((k, v) in map) {
                val key = k.toString()
                val value: Any? = when {
                    v == null -> null
                    key == "duration" -> v.toInt()
                    else -> v.toString()
                }
                converted[key] = value
            }
            out.add(converted)
        }
        return out
    }

    private fun runOnExecutor(result: MethodChannel.Result, block: () -> Any?) {
        executor.execute {
            try {
                val value = block()
                mainHandler.post { result.success(value) }
            } catch (t: Throwable) {
                val stack = t.stackTraceToString()
                mainHandler.post {
                    result.error("PYTHON_ERROR", t.message ?: "Unknown Python error", stack)
                }
            }
        }
    }
}
