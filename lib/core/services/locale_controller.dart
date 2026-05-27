import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _storageKey = 'app_language';

const Locale kDefaultLocale = Locale('tr');
const Locale kEnglishLocale = Locale('en');

final ValueNotifier<Locale> appLocale = ValueNotifier<Locale>(kDefaultLocale);

class LocaleController {
  LocaleController({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const MethodChannel _channel =
      MethodChannel('com.tevfik.tiktok_downloader/locale_prefs');

  final FlutterSecureStorage _storage;

  Future<void> loadInitial() async {
    final saved = await _storage.read(key: _storageKey);
    final code = saved == 'en' ? 'en' : 'tr';
    appLocale.value = code == 'en' ? kEnglishLocale : kDefaultLocale;
    await _pushToNative(code);
  }

  Future<void> setLocale(Locale locale) async {
    final code = locale.languageCode == 'en' ? 'en' : 'tr';
    await _storage.write(key: _storageKey, value: code);
    appLocale.value = code == 'en' ? kEnglishLocale : kDefaultLocale;
    await _pushToNative(code);
  }

  Future<void> _pushToNative(String code) async {
    try {
      await _channel.invokeMethod<void>('setLanguage', {'code': code});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('locale_prefs setLanguage failed: $e');
      }
    }
  }
}
