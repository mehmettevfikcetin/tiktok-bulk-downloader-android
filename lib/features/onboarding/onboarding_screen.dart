import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/cookie_service.dart';

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

  bool _importing = false;

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text('Could not open $url'),
        ),
      );
    }
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await widget.cookieService.importCookieFile();
      if (!mounted) return;
      if (ok) {
        widget.onCompleted();
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No file selected.'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text('Import failed: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Cookies')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'TikTok requires cookies from a logged-in browser to download '
                'your collections. Follow these steps:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _Step(
                number: 1,
                title: 'Install Firefox for Android',
                description:
                    'You need Firefox because Chrome on Android does not '
                    'support extensions.',
                action: OutlinedButton.icon(
                  onPressed: () => _open(_firefoxUrl),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Play Store'),
                ),
              ),
              const SizedBox(height: 20),
              _Step(
                number: 2,
                title: 'Install the cookies.txt extension',
                description:
                    'In Firefox, install the "cookies.txt" extension by '
                    'Lennon Hill from the Firefox Add-ons site.',
                action: OutlinedButton.icon(
                  onPressed: () => _open(_extensionUrl),
                  icon: const Icon(Icons.extension),
                  label: const Text('Open Add-on Page'),
                ),
              ),
              const SizedBox(height: 20),
              _Step(
                number: 3,
                title: 'Export your cookies',
                description:
                    'Log into TikTok in Firefox, then tap the extension '
                    'icon and export your cookies. Save the .txt file to '
                    'your phone (e.g. Downloads).',
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
                  _importing ? 'Importing…' : 'Import Cookie File',
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
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
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
