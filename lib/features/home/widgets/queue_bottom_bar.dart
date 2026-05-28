import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class QueueBottomBar extends StatelessWidget {
  const QueueBottomBar({
    super.key,
    required this.total,
    required this.completed,
    required this.skipped,
    required this.failed,
    required this.queueActive,
    required this.canStart,
    required this.onStart,
    required this.onCancel,
  });

  final int total;
  final int completed;
  final int skipped;
  final int failed;
  final bool queueActive;
  final bool canStart;
  final VoidCallback onStart;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasProgress = completed > 0 || skipped > 0 || failed > 0;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.outline.withValues(alpha: 0.5)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Counters(
              total: total,
              completed: completed,
              skipped: skipped,
              failed: failed,
              showSummary: queueActive || hasProgress,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: canStart ? onStart : null,
                    icon: Icon(
                      queueActive ? Icons.downloading : Icons.download,
                      size: 20,
                    ),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        queueActive
                            ? l10n.downloadingButton
                            : l10n.startButton(total),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: queueActive ? onCancel : null,
                    icon: const Icon(Icons.stop, size: 18),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l10n.cancel, maxLines: 1),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: queueActive ? AppTheme.error : null,
                      side: BorderSide(
                        color: queueActive
                            ? AppTheme.error.withValues(alpha: 0.5)
                            : AppTheme.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Counters extends StatelessWidget {
  const _Counters({
    required this.total,
    required this.completed,
    required this.skipped,
    required this.failed,
    required this.showSummary,
  });

  final int total;
  final int completed;
  final int skipped;
  final int failed;
  final bool showSummary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!showSummary) {
      return Text(
        l10n.videosFetched(total),
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.muted, fontSize: 12),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _stat(l10n.statDone, l10n.doneOverTotal(completed, total), AppTheme.success),
        _stat(l10n.statSkipped, '$skipped', AppTheme.warning),
        _stat(l10n.statFailed, '$failed', AppTheme.error),
      ],
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 11,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
