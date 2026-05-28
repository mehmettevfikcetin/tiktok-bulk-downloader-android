# Chaquopy — runtime + reflectively accessed classes
-keep class com.chaquo.python.** { *; }
-keep class * extends com.chaquo.python.PyObject { *; }
-dontwarn com.chaquo.python.**

# App classes reached from Python (Chaquopy) via reflection and from Flutter
# channels. The ** wildcard is required so nested/anonymous classes — e.g.
# DownloadService$ServiceProgressReporter, $CancelCheck, the EventChannel
# StreamHandler anon classes — are kept by name, not just the top-level types.
-keep class com.tevfik.tiktok_downloader.** { *; }
-keepclassmembers class com.tevfik.tiktok_downloader.** { *; }

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
