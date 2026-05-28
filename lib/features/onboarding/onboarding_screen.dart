import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/cookie_service.dart';
import '../../core/services/locale_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.cookieService,
    required this.onCompleted,
  });

  final CookieService cookieService;
  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _firefoxUrl =
      'https://play.google.com/store/apps/details?id=org.mozilla.firefox';
  static const _extensionUrl =
      'https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/';

  final LocaleController _localeController = LocaleController();

  bool _importing = false;

  void _toggleLanguage() {
    final isEnglish = appLocale.value.languageCode == 'en';
    _localeController.setLocale(isEnglish ? kDefaultLocale : kEnglishLocale);
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!ok) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.error,
          content: Text(l10n.couldNotOpenUrl(url)),
        ),
      );
    }
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    try {
      final ok = await widget.cookieService.importCookieFile();
      if (!mounted) return;
      if (ok) {
        widget.onCompleted();
      } else {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noFileSelected)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.error,
          content: Text(l10n.importFailed(e.toString())),
        ),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingTitle),
        actions: [
          TextButton(
            onPressed: _toggleLanguage,
            child: Text(
              appLocale.value.languageCode == 'en' ? 'EN' : 'TR',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cookie_outlined, color: AppTheme.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.onboardingIntro,
                        style: const TextStyle(
                          color: AppTheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _Step(
                number: 1,
                title: l10n.onboardingStep1Title,
                description: l10n.onboardingStep1Body,
                action: OutlinedButton.icon(
                  onPressed: () => _open(_firefoxUrl),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.openPlayStore),
                ),
              ),
              const SizedBox(height: 20),
              _Step(
                number: 2,
                title: l10n.onboardingStep2Title,
                description: l10n.onboardingStep2Body,
                action: OutlinedButton.icon(
                  onPressed: () => _open(_extensionUrl),
                  icon: const Icon(Icons.extension),
                  label: Text(l10n.openAddonPage),
                ),
              ),
              const SizedBox(height: 20),
              _Step(
                number: 3,
                title: l10n.onboardingStep3Title,
                description: l10n.onboardingStep3Body,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _importing ? null : _import,
                icon: _importing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_upload_outlined),
                label: Text(
                  _importing ? l10n.importing : l10n.importCookieFile,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.title,
    required this.description,
    this.action,
  });

  final int number;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: theme.textTheme.bodyMedium),
          if (action != null) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: action!),
          ],
        ],
      ),
    );
  }
}
