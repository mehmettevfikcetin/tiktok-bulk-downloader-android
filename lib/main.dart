import 'package:flutter/material.dart';

import 'core/services/cookie_service.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  runApp(const TikTokDownloaderApp());
}

class TikTokDownloaderApp extends StatelessWidget {
  const TikTokDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok Downloader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _Bootstrap(),
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

  @override
  void initState() {
    super.initState();
    _initialPath = _cookieService.getCookiePath();
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
