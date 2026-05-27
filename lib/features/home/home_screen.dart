import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/models/tiktok_video.dart';
import '../../core/services/cookie_service.dart';
import '../../core/services/download_queue_service.dart';
import '../../core/services/python_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../common/empty_state.dart';
import '../cookie/cookie_status_widget.dart';
import '../onboarding/onboarding_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/queue_bottom_bar.dart';
import 'widgets/queue_video_card.dart';
import 'widgets/url_input_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.cookieService});

  final CookieService cookieService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PythonService _python = PythonService();
  late final DownloadQueueService _queue = DownloadQueueService(_python);
  final TextEditingController _urlController = TextEditingController();

  bool _fetching = false;
  String? _fetchProgress;
  String? _ffmpegPath;
  CookieStatus _cookieStatus = CookieStatus.missing;
  int? _cookieAgeDays;
  List<TikTokVideo> _videos = const [];
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    _initFfmpeg();
    _refreshCookieStatus();
    _queue.addListener(_onQueueChanged);
  }

  @override
  void dispose() {
    _queue.removeListener(_onQueueChanged);
    _queue.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _onQueueChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initFfmpeg() async {
    try {
      final path = await _python.initFfmpeg();
      if (!mounted) return;
      setState(() => _ffmpegPath = path);
    } catch (e) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context).ffmpegInitFailed(e.toString()));
    }
  }

  Future<void> _refreshCookieStatus() async {
    final status = await widget.cookieService.getStatus();
    final age = await widget.cookieService.getCookieAgeDays();
    final path = await widget.cookieService.getCookiePath();
    if (!mounted) return;
    setState(() {
      _cookieStatus = status;
      _cookieAgeDays = age;
    });
    if (path != null) {
      try {
        await _python.setCookiePath(path);
      } catch (_) {
        // Non-fatal; surface only when fetch is attempted.
      }
    }
  }

  bool get _cookieUsable =>
      _cookieStatus == CookieStatus.valid ||
      _cookieStatus == CookieStatus.aging;

  bool get _canFetch =>
      !_fetching && _ffmpegPath != null && _cookieUsable && !_queue.isActive;

  bool get _canDownload =>
      _videos.isNotEmpty && !_queue.isActive && _cookieUsable;

  Future<void> _fetchLinks() async {
    final l10n = AppLocalizations.of(context);
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError(l10n.pasteTikTokFirst);
      return;
    }
    if (!_looksLikeTikTok(url)) {
      _showError(l10n.notATikTokUrl);
      return;
    }
    setState(() {
      _fetching = true;
      _fetchProgress = l10n.starting;
      _videos = const [];
      _hasFetched = false;
    });
    try {
      final videos = await _python.fetchLinks(url);
      if (!mounted) return;
      setState(() {
        _videos = videos;
        _hasFetched = true;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('$e');
    } finally {
      if (mounted) {
        setState(() {
          _fetching = false;
          _fetchProgress = null;
        });
      }
    }
  }

  Future<void> _startDownloads() async {
    if (_videos.isEmpty) return;
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notificationsDenied),
          duration: const Duration(seconds: 4),
        ),
      );
    }
    try {
      await _queue.start(_videos);
    } catch (e) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context).failedToStartDownloads(e.toString()));
    }
  }

  Future<void> _cancelDownloads() async {
    try {
      await _queue.cancel();
    } catch (e) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context).cancelFailed(e.toString()));
    }
  }

  Future<void> _retryVideo(TikTokVideo video) async {
    try {
      await _queue.retry(video);
    } catch (e) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context).retryFailed(e.toString()));
    }
  }

  bool _looksLikeTikTok(String url) {
    final u = url.toLowerCase();
    return u.contains('tiktok.com') ||
        u.contains('vm.tiktok.com') ||
        u.contains('vt.tiktok.com');
  }

  Future<void> _showCookieActions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        final l10n = AppLocalizations.of(sheetCtx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: CookieStatusWidget(
                  status: _cookieStatus,
                  ageDays: _cookieAgeDays,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(l10n.reimportCookieTitle),
                subtitle: Text(l10n.reimportCookieSubtitle),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _reimportCookie();
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: Text(l10n.openSettingsAction),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _openSettings();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reimportCookie() async {
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
      await _refreshCookieStatus();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).cookiesImported)),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context).reimportFailed(e.toString()));
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          cookieService: widget.cookieService,
          onCookieCleared: _onCookieCleared,
        ),
      ),
    );
    // Returning to home: refresh status in case cookie was re-imported.
    await _refreshCookieStatus();
  }

  Future<void> _onCookieCleared() async {
    if (_queue.isActive) {
      try {
        await _queue.cancel();
      } catch (_) {}
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => OnboardingScreen(
          cookieService: widget.cookieService,
          onCompleted: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) =>
                    HomeScreen(cookieService: widget.cookieService),
              ),
              (_) => false,
            );
          },
        ),
      ),
      (_) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 6),
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.bg),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          CookieStatusWidget(
            status: _cookieStatus,
            ageDays: _cookieAgeDays,
            onTap: _showCookieActions,
            compact: true,
          ),
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: UrlInputSection(
                controller: _urlController,
                canFetch: _canFetch,
                fetching: _fetching,
                queueActive: _queue.isActive,
                onFetch: _fetchLinks,
                progressStream: _python.linkProgressStream,
                initialProgress: _fetchProgress,
                showImportCookieAction: !_cookieUsable,
                onImportCookie: _reimportCookie,
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildQueueArea()),
            if (_videos.isNotEmpty)
              QueueBottomBar(
                total: _videos.length,
                completed: _queue.completedCount,
                skipped: _queue.skippedCount,
                failed: _queue.errorCount,
                queueActive: _queue.isActive,
                canStart: _canDownload,
                onStart: _startDownloads,
                onCancel: _cancelDownloads,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueArea() {
    final l10n = AppLocalizations.of(context);
    if (_videos.isEmpty) {
      if (_fetching) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!_cookieUsable) {
        return EmptyState(
          icon: Icons.cookie_outlined,
          title: l10n.cookiesNeededTitle,
          body: l10n.cookiesNeededBody,
          action: FilledButton.icon(
            onPressed: _reimportCookie,
            icon: const Icon(Icons.file_open),
            label: Text(l10n.importCookie),
          ),
        );
      }
      if (_hasFetched) {
        return EmptyState(
          icon: Icons.movie_filter_outlined,
          title: l10n.noVideosFoundTitle,
          body: l10n.noVideosFoundBody,
        );
      }
      return EmptyState(
        icon: Icons.link_off,
        title: l10n.noVideosYetTitle,
        body: l10n.noVideosYetBody,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: _videos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final video = _videos[i];
        return QueueVideoCard(
          key: ValueKey(video.id),
          video: video,
          event: _queue.eventFor(video.id),
          onRetry: _retryVideo,
        );
      },
    );
  }
}
