package com.tevfik.tiktok_downloader

import android.content.Context
import android.content.res.Configuration
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/**
 * Bridges the Dart-side selected app language to a plain SharedPreferences
 * file that native components (e.g. DownloadService) can read without going
 * through the Flutter engine. The Dart side calls `setLanguage(code)` on the
 * `com.tevfik.tiktok_downloader/locale_prefs` MethodChannel whenever the
 * user picks a language; this writes the code to prefs synchronously so the
 * background service can localize notification text on its next start.
 */
object LocalePrefsBridge {
    private const val CHANNEL = "com.tevfik.tiktok_downloader/locale_prefs"
    const val PREFS_NAME = "tiktok_downloader_prefs"
    const val KEY_LANGUAGE = "app_language"

    fun register(flutterEngine: FlutterEngine, context: Context) {
        val appContext = context.applicationContext
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setLanguage" -> {
                        val code = call.argument<String>("code") ?: "tr"
                        val normalized = if (code == "en") "en" else "tr"
                        appContext
                            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                            .edit()
                            .putString(KEY_LANGUAGE, normalized)
                            .apply()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    fun readLanguageCode(context: Context): String {
        val prefs = context.applicationContext
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val saved = prefs.getString(KEY_LANGUAGE, null)
        return if (saved == "en") "en" else "tr"
    }

    /**
     * Returns a Context whose configuration locale is overridden to the saved
     * app language. Use this to build NotificationCompat builders so the
     * notification text follows the in-app selection rather than the device
     * locale.
     */
    fun localizedContext(base: Context): Context {
        val code = readLanguageCode(base)
        val locale = Locale(code)
        Locale.setDefault(locale)
        val config = Configuration(base.resources.configuration)
        config.setLocale(locale)
        return base.createConfigurationContext(config)
    }
}
