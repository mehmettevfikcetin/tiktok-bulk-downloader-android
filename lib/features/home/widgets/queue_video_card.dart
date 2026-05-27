import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/download_progress_event.dart';
import '../../../core/models/tiktok_video.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/status_badge.dart';
import '../../errors/error_detail_screen.dart';

class QueueVideoCard extends StatefulWidget {
  const QueueVideoCard({
    super.key,
    required this.video,
    required this.event,
    required this.onRetry,
  });

  final TikTokVideo video;
  final DownloadProgressEvent? event;
  final Future<void> Function(TikTokVideo video) onRetry;

  @override
  State<QueueVideoCard> createState() => _QueueVideoCardState();
}

class _QueueVideoCardState extends State<QueueVideoCard> {
  bool _expanded = false;

  bool get _isFailed => widget.event?.status == DownloadStatus.error;

  void _toggleExpanded() {
    if (!_isFailed) return;
    setState(() => _expanded = !_expanded);
  }

  Future<void> _openErrorDetail() async {
    final e = widget.event;
    if (e == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ErrorDetailScreen(
          video: widget.video,
          event: e,
          onRetry: () => widget.onRetry(widget.video),
        ),
      ),
    );
  }

  Future<void> _copyError() async {
    final msg = widget.event?.error ?? '';
    if (msg.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: msg));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).errorCopiedToClipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final video = widget.video;
    final status = event?.status ?? DownloadStatus.queued;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isFailed ? _toggleExpanded : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumbnail(url: video.thumbnail),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            StatusBadge(status: status),
                            const SizedBox(width: 8),
                            Text(
                              video.durationLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.muted,
                              ),
                            ),
                            const Spacer(),
                            if (status == DownloadStatus.downloading)
                              Text(
                                '${event!.percent}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accent,
                                ),
                              )
                            else
                              _trailingIcon(status, video.id),
                          ],
                        ),
                        if (status == DownloadStatus.downloading) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (event!.percent.clamp(0, 100)) / 100,
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: _isFailed && _expanded
                    ? _ErrorExpansion(
                        message: event?.error ?? AppLocalizations.of(context).unknownError,
                        onRetry: () => widget.onRetry(widget.video),
                        onCopy: _copyError,
                        onViewFull: _openErrorDetail,
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trailingIcon(DownloadStatus status, String videoId) {
    switch (status) {
      case DownloadStatus.completed:
        return const Icon(Icons.check_circle, size: 18, color: AppTheme.success);
      case DownloadStatus.skipped:
        return const Icon(Icons.fast_forward, size: 18, color: AppTheme.warning);
      case DownloadStatus.error:
        return Hero(
          tag: 'error-$videoId',
          child: const Icon(Icons.error_outline, size: 18, color: AppTheme.error),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 72,
        height: 72,
        child: url.isEmpty
            ? _placeholder()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) => _placeholder(spinner: true),
                errorWidget: (_, _, _) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder({bool spinner = false}) {
    return Container(
      color: AppTheme.surfaceHigh,
      child: Center(
        child: spinner
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.movie_outlined, color: AppTheme.muted, size: 26),
      ),
    );
  }
}

class _ErrorExpansion extends StatelessWidget {
  const _ErrorExpansion({
    required this.message,
    required this.onRetry,
    required this.onCopy,
    required this.onViewFull,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCopy;
  final VoidCallback onViewFull;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = message.length > 140 ? '${message.substring(0, 140)}…' : message;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.08),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            preview,
            style: const TextStyle(
              color: AppTheme.error,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(l10n.retry),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, size: 16),
                label: Text(l10n.copy),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              TextButton.icon(
                onPressed: onViewFull,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(l10n.viewFullError),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
