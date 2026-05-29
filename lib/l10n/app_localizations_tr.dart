// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'TikTok İndirici';

  @override
  String get updateAvailableTitle => 'Güncelleme mevcut';

  @override
  String updateAvailableBody(String current, String latest) {
    return 'TikTok İndirici\'nin yeni bir sürümü mevcut.\n\nMevcut: v$current\n\nEn son: v$latest';
  }

  @override
  String get later => 'Daha sonra';

  @override
  String get download => 'İndir';

  @override
  String get onboardingTitle => 'Çerezleri Ayarla';

  @override
  String get onboardingIntro =>
      'TikTok, koleksiyonlarınızı indirmek için oturum açılmış bir tarayıcıdan çerezler gerektirir. Şu adımları izleyin:';

  @override
  String get onboardingStep1Title => 'Android için Firefox\'u yükleyin';

  @override
  String get onboardingStep1Body =>
      'Android\'de Chrome eklentileri desteklemediği için Firefox\'a ihtiyacınız var.';

  @override
  String get openPlayStore => 'Play Store\'u Aç';

  @override
  String get onboardingStep2Title => 'cookies.txt eklentisini yükleyin';

  @override
  String get onboardingStep2Body =>
      'Eklentiyi Firefox\'a manuel olarak eklemek için:\n1. Firefox\'ta sağ üstteki üç noktaya (⋮) dokunun\n2. \'Uzantılar\' seçeneğine dokunun\n3. En alta kaydırın, \'Daha fazla uzantı bul\'a dokunun\n4. Arama kutusuna \'cookies.txt\' yazın\n5. Çıkan eklentiye dokunun, \'Firefox\'a Ekle\' butonuna basın\n6. İzinleri kabul edin';

  @override
  String get openAddonPage => 'Firefox\'ta Eklenti Sayfasını Aç';

  @override
  String get onboardingStep3Title => 'Çerezlerinizi dışa aktarın';

  @override
  String get onboardingStep3Body =>
      'Cookies.txt dosyasını dışa aktarmak için:\n1. Firefox\'ta TikTok\'a giriş yapın\n2. Sağ üstteki üç noktaya (⋮) dokunun, \'Uzantılar\'a dokunun\n3. Listeden \'cookies.txt\' eklentisine dokunun\n4. Açılan ekranda \'Current Site\' satırındaki \'Download\' butonuna basın\n5. İndirme başlamazsa: telefondaki son uygulamalar ekranına çıkın (görev yöneticisi), ardından Firefox\'a tekrar dokunun — indirme paneli otomatik olarak gelecektir\n6. İndirilen .txt dosyasını bir yere kaydedin, sonraki adımda içe aktaracaksınız';

  @override
  String get importing => 'İçe aktarılıyor…';

  @override
  String get importCookieFile => 'Çerez Dosyasını İçe Aktar';

  @override
  String couldNotOpenUrl(String url) {
    return '$url açılamadı';
  }

  @override
  String get noFileSelected => 'Dosya seçilmedi.';

  @override
  String importFailed(String error) {
    return 'İçe aktarma başarısız: $error';
  }

  @override
  String get cookiesOkNoAge => 'Çerezler tamam';

  @override
  String cookiesOkWithAge(int days) {
    return 'Çerezler tamam (${days}g)';
  }

  @override
  String get cookiesAgingNoAge => 'Çerezler eskiyor';

  @override
  String cookiesAgingWithAge(int days) {
    return 'Çerezler eskiyor (${days}g)';
  }

  @override
  String get cookiesExpiredNoAge =>
      'Çerezlerin süresi doldu — yeniden içe aktarın';

  @override
  String cookiesExpiredWithAge(int days) {
    return 'Çerezlerin süresi doldu (${days}g) — yeniden içe aktarın';
  }

  @override
  String get noCookiesImported => 'Çerez içe aktarılmadı';

  @override
  String get pasteTikTokFirst => 'Önce bir TikTok URL\'si yapıştırın.';

  @override
  String get notATikTokUrl => 'Bu bir TikTok URL\'sine benzemiyor.';

  @override
  String get starting => 'Başlatılıyor…';

  @override
  String get notificationsDenied =>
      'Bildirimler reddedildi. İndirmeler yine de çalışacak ancak ilerleme bildirim çekmecesinde gösterilmeyecek.';

  @override
  String failedToStartDownloads(String error) {
    return 'İndirmeler başlatılamadı: $error';
  }

  @override
  String cancelFailed(String error) {
    return 'İptal başarısız: $error';
  }

  @override
  String retryFailed(String error) {
    return 'Yeniden deneme başarısız: $error';
  }

  @override
  String ffmpegInitFailed(String error) {
    return 'FFmpeg başlatılamadı: $error';
  }

  @override
  String get reimportCookieTitle => 'Çerezi Yeniden İçe Aktar';

  @override
  String get reimportCookieSubtitle => 'Yeni bir cookies.txt seçin';

  @override
  String get openSettingsAction => 'Ayarları Aç';

  @override
  String get cookiesImported => 'Çerezler içe aktarıldı.';

  @override
  String reimportFailed(String error) {
    return 'Yeniden içe aktarma başarısız: $error';
  }

  @override
  String get settingsTooltip => 'Ayarlar';

  @override
  String get cookiesNeededTitle => 'Çerez gerekiyor';

  @override
  String get cookiesNeededBody =>
      'TikTok videolarını almaya başlamak için bir cookies.txt dosyasını içe aktarın.';

  @override
  String get importCookie => 'Çerezi İçe Aktar';

  @override
  String get singleVideoNotice =>
      'Bu link tek bir video içeriyor. Koleksiyon indirmek için TikTok\'ta bir koleksiyon oluşturun ve o linki yapıştırın.';

  @override
  String get noVideosFoundTitle => 'Video bulunamadı';

  @override
  String get noVideosFoundBody =>
      'Bu URL hiçbir öğe döndürmedi. Farklı bir koleksiyon deneyin.';

  @override
  String get noVideosYetTitle => 'Henüz video yok';

  @override
  String get noVideosYetBody =>
      'Yukarıya bir TikTok koleksiyonu URL\'si yapıştırın ve Bağlantıları Getir\'e dokunun.';

  @override
  String get urlInputLabel => 'Koleksiyon URL\'si';

  @override
  String get urlInputHint => 'https://www.tiktok.com/@kullanici/collection/…';

  @override
  String get fetchLinks => 'Bağlantıları Getir';

  @override
  String get working => 'Çalışıyor…';

  @override
  String videosFetched(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '# video alındı',
    );
    return '$_temp0';
  }

  @override
  String get statDone => 'Tamamlandı';

  @override
  String get statSkipped => 'Atlandı';

  @override
  String get statFailed => 'Başarısız';

  @override
  String doneOverTotal(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String get downloadingButton => 'İndiriliyor…';

  @override
  String startButton(int total) {
    return 'Başlat ($total)';
  }

  @override
  String get pauseComingSoon => 'Duraklatma yakında';

  @override
  String get pause => 'Duraklat';

  @override
  String get cancel => 'İptal';

  @override
  String get errorCopiedToClipboard => 'Hata panoya kopyalandı';

  @override
  String get retry => 'Yeniden Dene';

  @override
  String get copy => 'Kopyala';

  @override
  String get viewFullError => 'Tüm hatayı görüntüle';

  @override
  String get errorScreenTitle => 'Hata';

  @override
  String get unknownError => 'Bilinmeyen hata';

  @override
  String get sectionCookies => 'Çerezler';

  @override
  String get sectionDownloadLocation => 'İndirme konumu';

  @override
  String get sectionAbout => 'Hakkında';

  @override
  String get sectionAppearance => 'Görünüm';

  @override
  String get reimportCookiesItem => 'Çerezleri yeniden içe aktar';

  @override
  String get reimportCookiesItemSub => 'Yeni bir cookies.txt dosyası seçin';

  @override
  String get clearCookies => 'Çerezleri temizle';

  @override
  String get clearCookiesSub => 'Onboarding\'e döner';

  @override
  String get downloadLocationBody =>
      'Dosyalar buraya kaydedilir. Klasör seçimi bu sürümde yapılandırılamaz.';

  @override
  String get aboutAppName => 'TikTok İndirici';

  @override
  String versionLabel(String version) {
    return 'Sürüm $version';
  }

  @override
  String get engine => 'Motor';

  @override
  String get engineSub => 'Chaquopy üzerinden yt-dlp';

  @override
  String get clearCookiesDialogTitle => 'Çerezler temizlensin mi?';

  @override
  String get clearCookiesDialogBody =>
      'İndirmeden önce çerezleri yeniden içe aktarmanız gerekecek. İndirilenler klasörünüzdeki mevcut indirmeler etkilenmez.';

  @override
  String get clear => 'Temizle';

  @override
  String clearCookiesFailed(String error) {
    return 'Çerezler temizlenemedi: $error';
  }

  @override
  String get language => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get statusSaved => 'Kaydedildi';

  @override
  String get statusSkipped => 'Atlandı';

  @override
  String get statusFailed => 'Başarısız';

  @override
  String get statusCancelled => 'İptal edildi';

  @override
  String get statusDownloading => 'İndiriliyor';

  @override
  String get statusPaused => 'Duraklatıldı';

  @override
  String get statusQueued => 'Sıraya alındı';

  @override
  String get statusDone => 'Tamamlandı';
}
