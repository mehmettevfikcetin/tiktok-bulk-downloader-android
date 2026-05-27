# jniLibs — FFmpeg binaries

This directory holds the statically-linked FFmpeg and FFprobe executables
that yt-dlp invokes at runtime to merge separate video and audio streams.

The files are **not** checked in. You must download and place them manually
before building the APK.

## Required layout

```
jniLibs/
  arm64-v8a/
    libffmpeg.so      (renamed `ffmpeg` binary)
    libffprobe.so     (renamed `ffprobe` binary)
  x86_64/
    libffmpeg.so
    libffprobe.so
```

The `lib*.so` rename is required so Android's installer treats them as native
libraries and extracts them to `nativeLibraryDir`, where they are exec-allowed
on Android 10+. They are not actually shared libraries — they are PIE
executables that happen to use the `.so` suffix.

## Source

Primary: https://github.com/yearsyan/ffmpeg-android-build/releases
  - `ffmpeg_android_aarch64_mini.tar.gz` -> arm64-v8a
  - `ffmpeg_android_x86_64_mini.tar.gz` -> x86_64

After extracting each tarball, copy the `ffmpeg` binary to
`libffmpeg.so` and the `ffprobe` binary to `libffprobe.so` in the
matching ABI folder above.

If the `mini` variant does not include `ffprobe`, use the `full` variant
from the same release.

## Build-time settings that depend on this

- `android:extractNativeLibs="true"` in `AndroidManifest.xml`
- `packaging { jniLibs { useLegacyPackaging = true } }` in `build.gradle.kts`

Both force the binaries to be stored uncompressed and extracted to disk at
install time, which is what makes them exec-able from Python's subprocess.
