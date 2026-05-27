import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/download_progress_event.dart';
import '../models/tiktok_video.dart';
import 'python_service.dart';

class DownloadQueueService extends ChangeNotifier {
  DownloadQueueService(this._python) {
    _subscription = _python.downloadProgressStream.listen(_onEvent);
  }

  final PythonService _python;
  StreamSubscription<DownloadProgressEvent>? _subscription;

  List<TikTokVideo> _videos = const [];
  final Map<String, DownloadProgressEvent> _eventsById = {};
  bool _isActive = false;
  int _currentIndex = 0;
  int _completed = 0;
  int _skipped = 0;
  int _errors = 0;

  List<TikTokVideo> get videos => _videos;
  bool get isActive => _isActive;
  int get currentIndex => _currentIndex;
  int get completedCount => _completed;
  int get skippedCount => _skipped;
  int get errorCount => _errors;
  int get totalCount => _videos.length;

  DownloadProgressEvent? eventFor(String videoId) => _eventsById[videoId];

  Future<void> start(List<TikTokVideo> videos) async {
    if (_isActive) return;
    _videos = List<TikTokVideo>.unmodifiable(videos);
    _eventsById.clear();
    _currentIndex = 0;
    _completed = 0;
    _skipped = 0;
    _errors = 0;
    _isActive = true;
    notifyListeners();
    try {
      await _python.startDownloads(_videos);
    } catch (e) {
      _isActive = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancel() async {
    if (!_isActive) return;
    await _python.cancelDownloads();
  }

  Future<void> pause() async {
    if (!_isActive) return;
    await _python.pauseDownloads();
  }

  Future<void> retry(TikTokVideo video) async {
    if (_isActive) return;
    _eventsById.remove(video.id);
    if (_errors > 0) _errors--;
    _isActive = true;
    notifyListeners();
    try {
      await _python.startDownloads([video]);
    } catch (e) {
      _isActive = false;
      notifyListeners();
      rethrow;
    }
  }

  void _onEvent(DownloadProgressEvent event) {
    if (event.status == DownloadStatus.queueFinished) {
      _completed = event.completedCount ?? _completed;
      _skipped = event.skippedCount ?? _skipped;
      _errors = event.errorCount ?? _errors;
      _isActive = false;
      _currentIndex = event.total;
      notifyListeners();
      return;
    }

    _currentIndex = event.index;
    if (event.videoId.isNotEmpty) {
      _eventsById[event.videoId] = event;
    }
    switch (event.status) {
      case DownloadStatus.completed:
        _completed++;
        break;
      case DownloadStatus.skipped:
        _skipped++;
        break;
      case DownloadStatus.error:
        _errors++;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
