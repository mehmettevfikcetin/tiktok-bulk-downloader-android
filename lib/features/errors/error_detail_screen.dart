import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/download_progress_event.dart';
import '../../core/models/tiktok_video.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ErrorDetailScreen extends StatelessWidget {
  const ErrorDetailScreen({
    super.key,
    required this.video,
    required this.event,
    required this.onRetry,
  });

  final TikTokVideo video;
  final DownloadProgressEvent event;
  final Future<void> Function() onRetry;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: event.error ?? ''));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).errorCopiedToClipboard)),
    );
  }

  Future<void> _retry(BuildContext context) async {
    Navigator.of(context).pop();
    await onRetry();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = event.error ?? l10n.unknownError;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.errorScreenTitle),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'error-${video.id}',
                    child: const Icon(
                      Icons.error_outline,
                      color: AppTheme.error,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                video.url,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      message,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.5,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _retry(context),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copy(context),
                      icon: const Icon(Icons.copy),
                      label: Text(l10n.copy),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
