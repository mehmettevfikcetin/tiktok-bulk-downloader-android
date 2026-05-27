package com.tevfik.tiktok_downloader

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.chaquo.python.PyObject
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

object PythonBridge {
    private const val CHANNEL = "com.tevfik.tiktok_downloader/python"
    private const val PROGRESS_CHANNEL = "com.tevfik.tiktok_downloader/link_progress"
    private const val TAG = "PythonBridge"
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    @Volatile
    private var progressSink: EventChannel.EventSink? = null

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

    fun register(flutterEngine: FlutterEngine, context: Context) {
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(context))
        }

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
                    else -> result.notImplemented()
                }
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
