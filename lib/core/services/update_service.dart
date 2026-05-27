import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseUrl,
    required this.releaseNotes,
  });

  final String currentVersion;
  final String latestVersion;
  final String releaseUrl;
  final String releaseNotes;
}

class UpdateService {
  static const String _releasesApi =
      'https://api.github.com/repos/mehmettevfikcetin/tiktok-bulk-downloader-android/releases/latest';

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      final response = await http
          .get(Uri.parse(_releasesApi), headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tag = (data['tag_name'] as String? ?? '').trim();
      final latest = tag.startsWith('v') ? tag.substring(1) : tag;
      if (latest.isEmpty) return null;

      if (!_isNewer(latest, current)) return null;

      return UpdateInfo(
        currentVersion: current,
        latestVersion: latest,
        releaseUrl: data['html_url'] as String? ?? '',
        releaseNotes: data['body'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  bool _isNewer(String latest, String current) {
    final a = _parse(latest);
    final b = _parse(current);
    for (var i = 0; i < 3; i++) {
      if (a[i] > b[i]) return true;
      if (a[i] < b[i]) return false;
    }
    return false;
  }

  List<int> _parse(String v) {
    final parts = v.split('.');
    final out = <int>[0, 0, 0];
    for (var i = 0; i < 3 && i < parts.length; i++) {
      out[i] = int.tryParse(parts[i].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return out;
  }
}
