import 'package:flutter/material.dart';

import '../../core/services/cookie_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class CookieStatusWidget extends StatelessWidget {
  const CookieStatusWidget({
    super.key,
    required this.status,
    this.ageDays,
    this.onTap,
    this.compact = false,
  });

  final CookieStatus status;
  final int? ageDays;
  final VoidCallback? onTap;

  /// When true, render as a small icon-only chip suitable for an AppBar.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, color, label) = _present(l10n);
    if (compact) {
      return IconButton(
        tooltip: label,
        onPressed: onTap,
        icon: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.cookie_outlined, color: color, size: 22),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.bg, width: 2),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final borderRadius = BorderRadius.circular(10);
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color, String) _present(AppLocalizations l10n) {
    switch (status) {
      case CookieStatus.valid:
        return (
          Icons.check_circle,
          AppTheme.success,
          ageDays == null ? l10n.cookiesOkNoAge : l10n.cookiesOkWithAge(ageDays!),
        );
      case CookieStatus.aging:
        return (
          Icons.warning_amber,
          AppTheme.warning,
          ageDays == null
              ? l10n.cookiesAgingNoAge
              : l10n.cookiesAgingWithAge(ageDays!),
        );
      case CookieStatus.expired:
        return (
          Icons.error,
          AppTheme.error,
          ageDays == null
              ? l10n.cookiesExpiredNoAge
              : l10n.cookiesExpiredWithAge(ageDays!),
        );
      case CookieStatus.missing:
        return (
          Icons.help_outline,
          AppTheme.muted,
          l10n.noCookiesImported,
        );
    }
  }
}
