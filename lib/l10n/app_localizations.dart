import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TikTok Downloader'**
  String get appTitle;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A newer version of TikTok Downloader is available.\n\nCurrent: v{current}\n\nLatest: v{latest}'**
  String updateAvailableBody(String current, String latest);

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Up Cookies'**
  String get onboardingTitle;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'TikTok requires cookies from a logged-in browser to download your collections. Follow these steps:'**
  String get onboardingIntro;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Install Firefox for Android'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Body.
  ///
  /// In en, this message translates to:
  /// **'You need Firefox because Chrome on Android does not support extensions.'**
  String get onboardingStep1Body;

  /// No description provided for @openPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Open Play Store'**
  String get openPlayStore;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Install the cookies.txt extension'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Body.
  ///
  /// In en, this message translates to:
  /// **'To manually add the extension to Firefox:\n1. Tap the three-dot menu (⋮) in Firefox\n2. Tap \'Add-ons\'\n3. Scroll to the bottom, tap \'Find more add-ons\'\n4. Search for \'cookies.txt\'\n5. Tap the extension, then tap \'Add to Firefox\'\n6. Accept the permissions'**
  String get onboardingStep2Body;

  /// No description provided for @openAddonPage.
  ///
  /// In en, this message translates to:
  /// **'Open Add-on Page in Firefox'**
  String get openAddonPage;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Export your cookies'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Body.
  ///
  /// In en, this message translates to:
  /// **'To export your cookies:\n1. Log into TikTok in Firefox\n2. Tap the three-dot menu (⋮), then tap \'Add-ons\'\n3. Tap \'cookies.txt\' from the list\n4. In the screen that appears, tap \'Download\' next to \'Current Site\'\n5. If the download does not start: open your recent apps screen, then tap Firefox again — the download panel will appear automatically\n6. Save the downloaded .txt file — you will import it in the next step'**
  String get onboardingStep3Body;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importing;

  /// No description provided for @importCookieFile.
  ///
  /// In en, this message translates to:
  /// **'Import Cookie File'**
  String get importCookieFile;

  /// No description provided for @couldNotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpenUrl(String url);

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected.'**
  String get noFileSelected;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @cookiesOkNoAge.
  ///
  /// In en, this message translates to:
  /// **'Cookies OK'**
  String get cookiesOkNoAge;

  /// No description provided for @cookiesOkWithAge.
  ///
  /// In en, this message translates to:
  /// **'Cookies OK ({days}d old)'**
  String cookiesOkWithAge(int days);

  /// No description provided for @cookiesAgingNoAge.
  ///
  /// In en, this message translates to:
  /// **'Cookies aging'**
  String get cookiesAgingNoAge;

  /// No description provided for @cookiesAgingWithAge.
  ///
  /// In en, this message translates to:
  /// **'Cookies aging ({days}d)'**
  String cookiesAgingWithAge(int days);

  /// No description provided for @cookiesExpiredNoAge.
  ///
  /// In en, this message translates to:
  /// **'Cookies expired — re-import'**
  String get cookiesExpiredNoAge;

  /// No description provided for @cookiesExpiredWithAge.
  ///
  /// In en, this message translates to:
  /// **'Cookies expired ({days}d) — re-import'**
  String cookiesExpiredWithAge(int days);

  /// No description provided for @noCookiesImported.
  ///
  /// In en, this message translates to:
  /// **'No cookies imported'**
  String get noCookiesImported;

  /// No description provided for @pasteTikTokFirst.
  ///
  /// In en, this message translates to:
  /// **'Paste a TikTok URL first.'**
  String get pasteTikTokFirst;

  /// No description provided for @notATikTokUrl.
  ///
  /// In en, this message translates to:
  /// **'That does not look like a TikTok URL.'**
  String get notATikTokUrl;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get starting;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications denied. Downloads will still run, but progress will not be shown in the notification shade.'**
  String get notificationsDenied;

  /// No description provided for @failedToStartDownloads.
  ///
  /// In en, this message translates to:
  /// **'Failed to start downloads: {error}'**
  String failedToStartDownloads(String error);

  /// No description provided for @cancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Cancel failed: {error}'**
  String cancelFailed(String error);

  /// No description provided for @retryFailed.
  ///
  /// In en, this message translates to:
  /// **'Retry failed: {error}'**
  String retryFailed(String error);

  /// No description provided for @ffmpegInitFailed.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg init failed: {error}'**
  String ffmpegInitFailed(String error);

  /// No description provided for @reimportCookieTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-import Cookie'**
  String get reimportCookieTitle;

  /// No description provided for @reimportCookieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a fresh cookies.txt'**
  String get reimportCookieSubtitle;

  /// No description provided for @openSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettingsAction;

  /// No description provided for @cookiesImported.
  ///
  /// In en, this message translates to:
  /// **'Cookies imported.'**
  String get cookiesImported;

  /// No description provided for @reimportFailed.
  ///
  /// In en, this message translates to:
  /// **'Re-import failed: {error}'**
  String reimportFailed(String error);

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @cookiesNeededTitle.
  ///
  /// In en, this message translates to:
  /// **'Cookies needed'**
  String get cookiesNeededTitle;

  /// No description provided for @cookiesNeededBody.
  ///
  /// In en, this message translates to:
  /// **'Import a cookies.txt file to start fetching TikTok videos.'**
  String get cookiesNeededBody;

  /// No description provided for @importCookie.
  ///
  /// In en, this message translates to:
  /// **'Import Cookie'**
  String get importCookie;

  /// No description provided for @singleVideoNotice.
  ///
  /// In en, this message translates to:
  /// **'This link contains a single video. To download collections, create a collection on TikTok and paste that link.'**
  String get singleVideoNotice;

  /// No description provided for @noVideosFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No videos found'**
  String get noVideosFoundTitle;

  /// No description provided for @noVideosFoundBody.
  ///
  /// In en, this message translates to:
  /// **'That URL returned no items. Try a different collection.'**
  String get noVideosFoundBody;

  /// No description provided for @noVideosYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No videos yet'**
  String get noVideosYetTitle;

  /// No description provided for @noVideosYetBody.
  ///
  /// In en, this message translates to:
  /// **'Paste a TikTok collection URL above and tap Fetch Links.'**
  String get noVideosYetBody;

  /// No description provided for @urlInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection URL'**
  String get urlInputLabel;

  /// No description provided for @urlInputHint.
  ///
  /// In en, this message translates to:
  /// **'https://www.tiktok.com/@user/collection/…'**
  String get urlInputHint;

  /// No description provided for @fetchLinks.
  ///
  /// In en, this message translates to:
  /// **'Fetch Links'**
  String get fetchLinks;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get working;

  /// No description provided for @videosFetched.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, one{# video fetched} other{# videos fetched}}'**
  String videosFetched(int total);

  /// No description provided for @statDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statDone;

  /// No description provided for @statSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statSkipped;

  /// No description provided for @statFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statFailed;

  /// No description provided for @doneOverTotal.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total}'**
  String doneOverTotal(int completed, int total);

  /// No description provided for @downloadingButton.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get downloadingButton;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start ({total})'**
  String startButton(int total);

  /// No description provided for @pauseComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Pause coming soon'**
  String get pauseComingSoon;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @errorCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Error copied to clipboard'**
  String get errorCopiedToClipboard;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @viewFullError.
  ///
  /// In en, this message translates to:
  /// **'View full error'**
  String get viewFullError;

  /// No description provided for @errorScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorScreenTitle;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @sectionCookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get sectionCookies;

  /// No description provided for @sectionDownloadLocation.
  ///
  /// In en, this message translates to:
  /// **'Download location'**
  String get sectionDownloadLocation;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @reimportCookiesItem.
  ///
  /// In en, this message translates to:
  /// **'Re-import cookies'**
  String get reimportCookiesItem;

  /// No description provided for @reimportCookiesItemSub.
  ///
  /// In en, this message translates to:
  /// **'Pick a fresh cookies.txt file'**
  String get reimportCookiesItemSub;

  /// No description provided for @clearCookies.
  ///
  /// In en, this message translates to:
  /// **'Clear cookies'**
  String get clearCookies;

  /// No description provided for @clearCookiesSub.
  ///
  /// In en, this message translates to:
  /// **'Returns to onboarding'**
  String get clearCookiesSub;

  /// No description provided for @downloadLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Files are saved here. Folder selection is not configurable in this version.'**
  String get downloadLocationBody;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'TikTok Downloader'**
  String get aboutAppName;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @engine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get engine;

  /// No description provided for @engineSub.
  ///
  /// In en, this message translates to:
  /// **'yt-dlp via Chaquopy'**
  String get engineSub;

  /// No description provided for @clearCookiesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cookies?'**
  String get clearCookiesDialogTitle;

  /// No description provided for @clearCookiesDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to import cookies again before downloading. Existing downloads in your Downloads folder are not affected.'**
  String get clearCookiesDialogBody;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearCookiesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cookies: {error}'**
  String clearCookiesFailed(String error);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @statusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get statusSaved;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get statusDownloading;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statusPaused;

  /// No description provided for @statusQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statusQueued;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
