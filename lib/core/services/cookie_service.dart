import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

enum CookieStatus { missing, valid, aging, expired }

class CookieService {
  static const String _kPath = 'cookie_path';
  static const String _kImportedAt = 'cookie_imported_at';

  static const int _agingDays = 7;
  static const int _expiredDays = 30;

  final FlutterSecureStorage _storage;

  CookieService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String> _cookieDestinationPath() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final cookiesDir = Directory('${docsDir.path}/cookies');
    if (!await cookiesDir.exists()) {
      await cookiesDir.create(recursive: true);
    }
    return '${cookiesDir.path}/cookies.txt';
  }

  Future<bool> importCookieFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return false;

    final picked = result.files.single;
    final sourcePath = picked.path;
    if (sourcePath == null) return false;

    final source = File(sourcePath);
    if (!await source.exists()) return false;

    final destPath = await _cookieDestinationPath();
    final dest = File(destPath);
    if (await dest.exists()) {
      await dest.delete();
    }
    await source.copy(destPath);

    await _storage.write(key: _kPath, value: destPath);
    await _storage.write(
      key: _kImportedAt,
      value: DateTime.now().toIso8601String(),
    );
    return true;
  }

  Future<String?> getCookiePath() async {
    final stored = await _storage.read(key: _kPath);
    if (stored == null) return null;
    if (!File(stored).existsSync()) return null;
    return stored;
  }

  Future<DateTime?> getImportedAt() async {
    final raw = await _storage.read(key: _kImportedAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<int?> getCookieAgeDays() async {
    final imported = await getImportedAt();
    if (imported == null) return null;
    return DateTime.now().difference(imported).inDays;
  }

  Future<CookieStatus> getStatus() async {
    final path = await getCookiePath();
    if (path == null) return CookieStatus.missing;
    final age = await getCookieAgeDays();
    if (age == null) return CookieStatus.missing;
    if (age < _agingDays) return CookieStatus.valid;
    if (age <= _expiredDays) return CookieStatus.aging;
    return CookieStatus.expired;
  }

  Future<void> clearCookie() async {
    final path = await _storage.read(key: _kPath);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _storage.delete(key: _kPath);
    await _storage.delete(key: _kImportedAt);
  }
}
