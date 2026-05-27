# Chaquopy — runtime + reflectively accessed classes
-keep class com.chaquo.python.** { *; }
-keep class * extends com.chaquo.python.PyObject { *; }
-dontwarn com.chaquo.python.**

# App entry points and classes called from Python via reflection
-keep class com.tevfik.tiktok_downloader.MainActivity { *; }
-keep class com.tevfik.tiktok_downloader.PythonBridge { *; }
-keep class com.tevfik.tiktok_downloader.DownloadService { *; }
-keep class com.tevfik.tiktok_downloader.FileStorageHelper { *; }

# Flutter embedding (precautionary)
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Play Core — Flutter embedding references SplitCompatApplication / SplitInstallManager
# for deferred-components support even when we don't use them. Suppress and keep.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Reflection / serialization safety
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes *Annotation*
