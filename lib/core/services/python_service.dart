import 'package:flutter/services.dart';

import '../models/download_progress_event.dart';
import '../models/tiktok_video.dart';

class PythonService {
  static const MethodChannel _channel =
      MethodChannel('com.tevfik.tiktok_downloader/python');

  static const EventChannel _progressChannel =
      EventChannel('com.tevfik.tiktok_downloader/link_progress');

  static const EventChannel _downloadProgressChannel =
      EventChannel('com.tevfik.tiktok_downloader/download_progress');

  Stream<String> get linkProgressStream =>
      _progressChannel.receiveBroadcastStream().map((event) => event.toString());

  Stream<DownloadProgressEvent> get downloadProgressStream =>
      _downloadProgressChannel
          .receiveBroadcastStream()
          .map((event) =>
              DownloadProgressEvent.fromMap(event as Map<dynamic, dynamic>));

  Future<String> getYtdlpVersion() async {
    final result = await _channel.invokeMethod<String>('getYtdlpVersion');
    if (result == null) {
      throw StateError('Python returned null version');
    }
    return result;
  }

  Future<String> initFfmpeg() async {
    final result = await _channel.invokeMethod<String>('initFfmpeg');
    if (result == null) {
      throw StateError('initFfmpeg returned null');
    }
    return result;
  }

  Future<String> testDownload(String url, String outputDir) async {
    final result = await _channel.invokeMethod<String>('testDownload', {
      'url': url,
      'outputDir': outputDir,
    });
    if (result == null) {
      throw StateError('testDownload returned null');
    }
    return result;
  }

  Future<void> setCookiePath(String path) async {
    await _channel.invokeMethod<void>('setCookiePath', {'path': path});
  }

  Future<List<TikTokVideo>> fetchLinks(String url) async {
    final raw = await _channel.invokeMethod<List<dynamic>>('fetchLinks', {
      'url': url,
    });
    if (raw == null) {
      throw StateError('fetchLinks returned null');
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(TikTokVideo.fromMap)
        .toList(growable: false);
  }

  Future<void> startDownloads(List<TikTokVideo> videos) async {
    final payload = videos
        .map((v) => {
              'id': v.id,
              'url': v.url,
              'title': v.title,
            })
        .toList(growable: false);
    await _channel.invokeMethod<void>('startDownloads', {'videos': payload});
  }

  Future<void> pauseDownloads() async {
    await _channel.invokeMethod<void>('pauseDownloads');
  }

  Future<void> cancelDownloads() async {
    await _channel.invokeMethod<void>('cancelDownloads');
  }

  Future<bool> isDownloadServiceRunning() async {
    final result =
        await _channel.invokeMethod<bool>('isDownloadServiceRunning');
    return result ?? false;
  }
}
