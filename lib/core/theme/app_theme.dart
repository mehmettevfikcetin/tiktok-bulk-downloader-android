import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/download_progress_event.dart';

class AppTheme {
  AppTheme._();

  static const String appVersion = '1.0.0';

  // Catppuccin Mocha-derived palette (Material 3-tuned, not verbatim).
  static const Color bg = Color(0xFF1E1E2E);
  static const Color surface = Color(0xFF313244);
  static const Color surfaceHigh = Color(0xFF45475A);
  static const Color outline = Color(0xFF585B70);
  static const Color onSurface = Color(0xFFCDD6F4);
  static const Color muted = Color(0xFF7F849C);

  static const Color accent = Color(0xFF89B4FA);
  static const Color accentHover = Color(0xFFB4BEFE);
  static const Color success = Color(0xFFA6E3A1);
  static const Color warning = Color(0xFFFAB387);
  static const Color error = Color(0xFFF38BA8);

  static ThemeData dark() {
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accent,
      onPrimary: bg,
      primaryContainer: surfaceHigh,
      onPrimaryContainer: onSurface,
      secondary: accentHover,
      onSecondary: bg,
      secondaryContainer: surfaceHigh,
      onSecondaryContainer: onSurface,
      tertiary: warning,
      onTertiary: bg,
      error: error,
      onError: bg,
      errorContainer: Color(0xFF4A2530),
      onErrorContainer: error,
      surface: bg,
      onSurface: onSurface,
      surfaceContainerLowest: bg,
      surfaceContainerLow: Color(0xFF272739),
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: Color(0xFF505264),
      onSurfaceVariant: muted,
      outline: outline,
      outlineVariant: Color(0xFF3E4055),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: onSurface,
      onInverseSurface: bg,
      inversePrimary: accent,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: bg,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: outline.withValues(alpha: 0.4), width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outline.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: muted),
        labelStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: bg,
          disabledBackgroundColor: surfaceHigh,
          disabledForegroundColor: muted,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: bg,
          disabledBackgroundColor: surfaceHigh,
          disabledForegroundColor: muted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: onSurface),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: surfaceHigh,
        circularTrackColor: surfaceHigh,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: onSurface,
        textColor: onSurface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: const TextStyle(color: onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
    );
  }

  static Color statusColor(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return success;
      case DownloadStatus.skipped:
        return warning;
      case DownloadStatus.error:
        return error;
      case DownloadStatus.cancelled:
        return muted;
      case DownloadStatus.downloading:
        return accent;
      case DownloadStatus.paused:
        return warning;
      case DownloadStatus.queued:
      case DownloadStatus.queueFinished:
        return muted;
    }
  }

}
