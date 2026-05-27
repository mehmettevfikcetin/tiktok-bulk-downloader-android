import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/services/cookie_service.dart';
import 'core/services/locale_controller.dart';
import 'core/services/update_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleController().loadInitial();
  runApp(const TikTokDownloaderApp());
}

class TikTokDownloaderApp extends StatelessWidget {
  const TikTokDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          navigatorKey: _navigatorKey,
          locale: locale,
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const _Bootstrap(),
        );
      },
    );
  }
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  final CookieService _cookieService = CookieService();
  late Future<String?> _initialPath;
  bool _updateChecked = false;

  @override
  void initState() {
    super.initState();
    _initialPath = _cookieService.getCookiePath();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runUpdateCheck());
  }

  Future<void> _runUpdateCheck() async {
    if (_updateChecked) return;
    _updateChecked = true;
    final info = await UpdateService().checkForUpdate();
    if (info == null) return;
    final ctx = _navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    await _showUpdateDialog(ctx, info);
  }

  Future<void> _showUpdateDialog(BuildContext ctx, UpdateInfo info) async {
    final accept = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) {
        final dl10n = AppLocalizations.of(dialogCtx);
        return AlertDialog(
          title: Text(dl10n.updateAvailableTitle),
          content: Text(
            dl10n.updateAvailableBody(
              info.currentVersion,
              info.latestVersion,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: Text(dl10n.later),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: Text(dl10n.download),
            ),
          ],
        );
      },
    );
    if (accept == true && info.releaseUrl.isNotEmpty) {
      final uri = Uri.tryParse(info.releaseUrl);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _onOnboardingCompleted() {
    setState(() {
      _initialPath = _cookieService.getCookiePath();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _initialPath,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppTheme.bg,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          return OnboardingScreen(
            cookieService: _cookieService,
            onCompleted: _onOnboardingCompleted,
          );
        }
        return HomeScreen(cookieService: _cookieService);
      },
    );
  }
}
