import 'package:flutter/material.dart';

import '../../core/services/cookie_service.dart';
import '../../core/services/locale_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../cookie/cookie_status_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.cookieService,
    required this.onCookieCleared,
  });

  final CookieService cookieService;
  final VoidCallback onCookieCleared;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocaleController _localeController = LocaleController();

  CookieStatus _status = CookieStatus.missing;
  int? _ageDays;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final status = await widget.cookieService.getStatus();
    final age = await widget.cookieService.getCookieAgeDays();
    if (!mounted) return;
    setState(() {
      _status = status;
      _ageDays = age;
      _loading = false;
    });
  }

  Future<void> _reimport() async {
    try {
      final ok = await widget.cookieService.importCookieFile();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noFileSelected)),
        );
        return;
      }
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).cookiesImported)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).reimportFailed(e.toString())),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _confirmClear() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cl10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(cl10n.clearCookiesDialogTitle),
          content: Text(cl10n.clearCookiesDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cl10n.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(cl10n.clear),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      await widget.cookieService.clearCookie();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).clearCookiesFailed(e.toString())),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    widget.onCookieCleared();
    // Reference l10n to silence the analyzer (we read it pre-await for
    // consistency, but the actual messages now come from inside the dialog).
    // ignore: unnecessary_statements
    l10n;
  }

  Future<void> _pickLanguage() async {
    final selected = await showModalBottomSheet<Locale>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        final l10n = AppLocalizations.of(sheetCtx);
        final current = appLocale.value;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.language,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              RadioGroup<Locale>(
                groupValue: current,
                onChanged: (loc) {
                  if (loc != null) Navigator.of(sheetCtx).pop(loc);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<Locale>(
                      value: kDefaultLocale,
                      title: Text(l10n.languageTurkish),
                    ),
                    RadioListTile<Locale>(
                      value: kEnglishLocale,
                      title: Text(l10n.languageEnglish),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    await _localeController.setLocale(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTooltip)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _sectionHeader(l10n.sectionCookies),
                  const SizedBox(height: 10),
                  Center(
                    child: CookieStatusWidget(
                      status: _status,
                      ageDays: _ageDays,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.refresh),
                          title: Text(l10n.reimportCookiesItem),
                          subtitle: Text(l10n.reimportCookiesItemSub),
                          onTap: _reimport,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.delete_outline,
                            color: AppTheme.error,
                          ),
                          title: Text(
                            l10n.clearCookies,
                            style: const TextStyle(color: AppTheme.error),
                          ),
                          subtitle: Text(l10n.clearCookiesSub),
                          onTap: _confirmClear,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader(l10n.sectionAppearance),
                  const SizedBox(height: 10),
                  Card(
                    child: ValueListenableBuilder<Locale>(
                      valueListenable: appLocale,
                      builder: (context, locale, _) {
                        final isEnglish = locale.languageCode == 'en';
                        return ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(l10n.language),
                          subtitle: Text(
                            isEnglish ? l10n.languageEnglish : l10n.languageTurkish,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _pickLanguage,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader(l10n.sectionDownloadLocation),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: const Text('Downloads/TikTok Downloader/'),
                      subtitle: Text(l10n.downloadLocationBody),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader(l10n.sectionAbout),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: Text(l10n.aboutAppName),
                          subtitle: Text(l10n.versionLabel(AppTheme.appVersion)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.code),
                          title: Text(l10n.engine),
                          subtitle: Text(l10n.engineSub),
                          onTap: null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
