import 'package:flutter/material.dart';

import '../../core/services/cookie_service.dart';

class CookieStatusWidget extends StatelessWidget {
  const CookieStatusWidget({
    super.key,
    required this.status,
    this.ageDays,
  });

  final CookieStatus status;
  final int? ageDays;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _present();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _present() {
    switch (status) {
      case CookieStatus.valid:
        return (
          Icons.check_circle,
          Colors.green,
          'Cookies OK${ageDays == null ? '' : ' (${ageDays}d old)'}',
        );
      case CookieStatus.aging:
        return (
          Icons.warning_amber,
          Colors.amber,
          'Cookies aging${ageDays == null ? '' : ' (${ageDays}d)'}',
        );
      case CookieStatus.expired:
        return (
          Icons.error,
          Colors.red,
          'Cookies expired${ageDays == null ? '' : ' (${ageDays}d)'} — re-import',
        );
      case CookieStatus.missing:
        return (
          Icons.help_outline,
          Colors.grey,
          'No cookies imported',
        );
    }
  }
}
