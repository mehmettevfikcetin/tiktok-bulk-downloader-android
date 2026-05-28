// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TikTok Downloader';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String current, String latest) {
    return 'A newer version of TikTok Downloader is available.\n\nCurrent: v$current\n\nLatest: v$latest';
  }

  @override
  String get later => 'Later';

  @override
  String get download => 'Download';

  @override
  String get onboardingTitle => 'Set Up Cookies';

  @override
  String get onboardingIntro =>
      'TikTok requires cookies from a logged-in browser to download your collections. Follow these steps:';

  @override
  String get onboardingStep1Title => 'Install Firefox for Android';

  @override
  String get onboardingStep1Body =>
      'You need Firefox because Chrome on Android does not support extensions.';

  @override
  String get openPlayStore => 'Open Play Store';

  @override
  String get onboardingStep2Title => 'Install the cookies.txt extension';

  @override
  String get onboardingStep2Body =>
      'To manually add the extension to Firefox:\n1. Tap the three-dot menu (⋮) in Firefox\n2. Tap \'Add-ons\'\n3. Scroll to the bottom, tap \'Find more add-ons\'\n4. Search for \'cookies.txt\'\n5. Tap the extension, then tap \'Add to Firefox\'\n6. Accept the permissions';

  @override
  String get openAddonPage => 'Open Add-on Page in Firefox';

  @override
  String get onboardingStep3Title => 'Export your cookies';

  @override
  String get onboardingStep3Body =>
      'To export your cookies:\n1. Log into TikTok in Firefox\n2. Tap the three-dot menu (⋮), then tap \'Add-ons\'\n3. Tap \'cookies.txt\' from the list\n4. In the screen that appears, tap \'Download\' next to \'Current Site\'\n5. If the download does not start: open your recent apps screen, then tap Firefox again — the download panel will appear automatically\n6. Save the downloaded .txt file — you will import it in the next step';

  @override
  String get importing => 'Importing…';

  @override
  String get importCookieFile => 'Import Cookie File';

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String get noFileSelected => 'No file selected.';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get cookiesOkNoAge => 'Cookies OK';

  @override
  String cookiesOkWithAge(int days) {
    return 'Cookies OK (${days}d old)';
  }

  @override
  String get cookiesAgingNoAge => 'Cookies aging';

  @override
  String cookiesAgingWithAge(int days) {
    return 'Cookies aging (${days}d)';
  }

  @override
  String get cookiesExpiredNoAge => 'Cookies expired — re-import';

  @override
  String cookiesExpiredWithAge(int days) {
    return 'Cookies expired (${days}d) — re-import';
  }

  @override
  String get noCookiesImported => 'No cookies imported';

  @override
  String get pasteTikTokFirst => 'Paste a TikTok URL first.';

  @override
  String get notATikTokUrl => 'That does not look like a TikTok URL.';

  @override
  String get starting => 'Starting…';

  @override
  String get notificationsDenied =>
      'Notifications denied. Downloads will still run, but progress will not be shown in the notification shade.';

  @override
  String failedToStartDownloads(String error) {
    return 'Failed to start downloads: $error';
  }

  @override
  String cancelFailed(String error) {
    return 'Cancel failed: $error';
  }

  @override
  String retryFailed(String error) {
    return 'Retry failed: $error';
  }

  @override
  String ffmpegInitFailed(String error) {
    return 'FFmpeg init failed: $error';
  }

  @override
  String get reimportCookieTitle => 'Re-import Cookie';

  @override
  String get reimportCookieSubtitle => 'Pick a fresh cookies.txt';

  @override
  String get openSettingsAction => 'Open Settings';

  @override
  String get cookiesImported => 'Cookies imported.';

  @override
  String reimportFailed(String error) {
    return 'Re-import failed: $error';
  }

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get cookiesNeededTitle => 'Cookies needed';

  @override
  String get cookiesNeededBody =>
      'Import a cookies.txt file to start fetching TikTok videos.';

  @override
  String get importCookie => 'Import Cookie';

  @override
  String get singleVideoNotice =>
      'This link contains a single video. To download collections, create a collection on TikTok and paste that link.';

  @override
  String get noVideosFoundTitle => 'No videos found';

  @override
  String get noVideosFoundBody =>
      'That URL returned no items. Try a different collection.';

  @override
  String get noVideosYetTitle => 'No videos yet';

  @override
  String get noVideosYetBody =>
      'Paste a TikTok collection URL above and tap Fetch Links.';

  @override
  String get urlInputLabel => 'Collection URL';

  @override
  String get urlInputHint => 'https://www.tiktok.com/@user/collection/…';

  @override
  String get fetchLinks => 'Fetch Links';

  @override
  String get working => 'Working…';

  @override
  String videosFetched(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '# videos fetched',
      one: '# video fetched',
    );
    return '$_temp0';
  }

  @override
  String get statDone => 'Done';

  @override
  String get statSkipped => 'Skipped';

  @override
  String get statFailed => 'Failed';

  @override
  String doneOverTotal(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String get downloadingButton => 'Downloading…';

  @override
  String startButton(int total) {
    return 'Start ($total)';
  }

  @override
  String get pauseComingSoon => 'Pause coming soon';

  @override
  String get pause => 'Pause';

  @override
  String get cancel => 'Cancel';

  @override
  String get errorCopiedToClipboard => 'Error copied to clipboard';

  @override
  String get retry => 'Retry';

  @override
  String get copy => 'Copy';

  @override
  String get viewFullError => 'View full error';

  @override
  String get errorScreenTitle => 'Error';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get sectionCookies => 'Cookies';

  @override
  String get sectionDownloadLocation => 'Download location';

  @override
  String get sectionAbout => 'About';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get reimportCookiesItem => 'Re-import cookies';

  @override
  String get reimportCookiesItemSub => 'Pick a fresh cookies.txt file';

  @override
  String get clearCookies => 'Clear cookies';

  @override
  String get clearCookiesSub => 'Returns to onboarding';

  @override
  String get downloadLocationBody =>
      'Files are saved here. Folder selection is not configurable in this version.';

  @override
  String get aboutAppName => 'TikTok Downloader';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get engine => 'Engine';

  @override
  String get engineSub => 'yt-dlp via Chaquopy';

  @override
  String get clearCookiesDialogTitle => 'Clear cookies?';

  @override
  String get clearCookiesDialogBody =>
      'You\'ll need to import cookies again before downloading. Existing downloads in your Downloads folder are not affected.';

  @override
  String get clear => 'Clear';

  @override
  String clearCookiesFailed(String error) {
    return 'Failed to clear cookies: $error';
  }

  @override
  String get language => 'Language';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get statusSaved => 'Saved';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusDownloading => 'Downloading';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusQueued => 'Queued';

  @override
  String get statusDone => 'Done';
}
