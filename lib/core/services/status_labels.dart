import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../models/download_progress_event.dart';

String downloadStatusLabel(BuildContext context, DownloadStatus status) {
  final l10n = AppLocalizations.of(context);
  switch (status) {
    case DownloadStatus.completed:
      return l10n.statusSaved;
    case DownloadStatus.skipped:
      return l10n.statusSkipped;
    case DownloadStatus.error:
      return l10n.statusFailed;
    case DownloadStatus.cancelled:
      return l10n.statusCancelled;
    case DownloadStatus.downloading:
      return l10n.statusDownloading;
    case DownloadStatus.paused:
      return l10n.statusPaused;
    case DownloadStatus.queued:
      return l10n.statusQueued;
    case DownloadStatus.queueFinished:
      return l10n.statusDone;
  }
}
