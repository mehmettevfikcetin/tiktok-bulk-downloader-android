enum DownloadStatus {
  queued,
  downloading,
  completed,
  skipped,
  error,
  paused,
  cancelled,
  queueFinished,
}

DownloadStatus _parseStatus(String? raw) {
  switch (raw) {
    case 'downloading':
      return DownloadStatus.downloading;
    case 'completed':
      return DownloadStatus.completed;
    case 'skipped':
      return DownloadStatus.skipped;
    case 'error':
      return DownloadStatus.error;
    case 'paused':
      return DownloadStatus.paused;
    case 'cancelled':
      return DownloadStatus.cancelled;
    case 'queue_finished':
      return DownloadStatus.queueFinished;
    default:
      return DownloadStatus.queued;
  }
}

class DownloadProgressEvent {
  const DownloadProgressEvent({
    required this.videoId,
    required this.index,
    required this.total,
    required this.percent,
    required this.status,
    required this.title,
    this.error,
    this.completedCount,
    this.skippedCount,
    this.errorCount,
    this.cancelledCount,
  });

  final String videoId;
  final int index;
  final int total;
  final int percent;
  final DownloadStatus status;
  final String title;
  final String? error;

  // Populated only on queueFinished events.
  final int? completedCount;
  final int? skippedCount;
  final int? errorCount;
  final int? cancelledCount;

  factory DownloadProgressEvent.fromMap(Map<dynamic, dynamic> map) {
    int asInt(Object? v) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    int? asIntOrNull(Object? v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return DownloadProgressEvent(
      videoId: (map['videoId'] ?? '').toString(),
      index: asInt(map['index']),
      total: asInt(map['total']),
      percent: asInt(map['percent']),
      status: _parseStatus(map['status']?.toString()),
      title: (map['title'] ?? '').toString(),
      error: map['error']?.toString(),
      completedCount: asIntOrNull(map['completed']),
      skippedCount: asIntOrNull(map['skipped']),
      errorCount: asIntOrNull(map['errors']),
      cancelledCount: asIntOrNull(map['cancelled']),
    );
  }
}
