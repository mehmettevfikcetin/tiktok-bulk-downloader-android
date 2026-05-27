import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class UrlInputSection extends StatelessWidget {
  const UrlInputSection({
    super.key,
    required this.controller,
    required this.canFetch,
    required this.fetching,
    required this.queueActive,
    required this.onFetch,
    required this.progressStream,
    this.initialProgress,
    this.showImportCookieAction = false,
    this.onImportCookie,
  });

  final TextEditingController controller;
  final bool canFetch;
  final bool fetching;
  final bool queueActive;
  final VoidCallback onFetch;
  final Stream<String> progressStream;
  final String? initialProgress;
  final bool showImportCookieAction;
  final VoidCallback? onImportCookie;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          enabled: !fetching && !queueActive,
          maxLines: 2,
          minLines: 1,
          decoration: InputDecoration(
            labelText: l10n.urlInputLabel,
            hintText: l10n.urlInputHint,
            prefixIcon: const Icon(Icons.link, color: AppTheme.muted),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: canFetch ? onFetch : null,
                icon: const Icon(Icons.search, size: 20),
                label: Text(l10n.fetchLinks),
              ),
            ),
            if (showImportCookieAction) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onImportCookie,
                icon: const Icon(Icons.cookie_outlined, size: 18),
                label: Text(l10n.importCookie),
              ),
            ],
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: fetching
              ? Padding(
                  key: const ValueKey('fetch-progress'),
                  padding: const EdgeInsets.only(top: 12),
                  child: _FetchProgress(
                    stream: progressStream,
                    initial: initialProgress,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('fetch-idle')),
        ),
      ],
    );
  }
}

class _FetchProgress extends StatelessWidget {
  const _FetchProgress({required this.stream, this.initial});

  final Stream<String> stream;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        final msg = snapshot.data ?? initial ?? AppLocalizations.of(context).working;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.outline),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
