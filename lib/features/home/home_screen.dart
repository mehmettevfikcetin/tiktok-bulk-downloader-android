import 'package:flutter/material.dart';

import '../../core/models/tiktok_video.dart';
import '../../core/services/cookie_service.dart';
import '../../core/services/python_service.dart';
import '../cookie/cookie_status_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.cookieService});

  final CookieService cookieService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PythonService _python = PythonService();
  final TextEditingController _urlController = TextEditingController();

  bool _loading = false;
  String? _progress;
  String? _ffmpegPath;
  CookieStatus _cookieStatus = CookieStatus.missing;
  int? _cookieAgeDays;
  List<TikTokVideo> _videos = const [];

  @override
  void initState() {
    super.initState();
    _initFfmpeg();
    _refreshCookieStatus();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _initFfmpeg() async {
    try {
      final path = await _python.initFfmpeg();
      if (!mounted) return;
      setState(() => _ffmpegPath = path);
    } catch (e) {
      if (!mounted) return;
      _showError('FFmpeg init failed: $e');
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

  bool get _canFetch =>
      !_loading &&
      _ffmpegPath != null &&
      (_cookieStatus == CookieStatus.valid ||
          _cookieStatus == CookieStatus.aging);

  Future<void> _fetchLinks() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Paste a TikTok URL first.');
      return;
    }
    if (!_looksLikeTikTok(url)) {
      _showError('That does not look like a TikTok URL.');
      return;
    }
    setState(() {
      _loading = true;
      _progress = 'Starting…';
      _videos = const [];
    });
    try {
      final videos = await _python.fetchLinks(url);
      if (!mounted) return;
      setState(() => _videos = videos);
    } catch (e) {
      if (!mounted) return;
      _showError('$e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _progress = null;
        });
      }
    }
  }

  bool _looksLikeTikTok(String url) {
    final u = url.toLowerCase();
    return u.contains('tiktok.com') ||
        u.contains('vm.tiktok.com') ||
        u.contains('vt.tiktok.com');
  }

  Future<void> _reimportCookie() async {
    try {
      final ok = await widget.cookieService.importCookieFile();
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected.')),
        );
        return;
      }
      await _refreshCookieStatus();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cookies imported.')),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Re-import failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 6),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TikTok Downloader')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CookieStatusWidget(
                      status: _cookieStatus,
                      ageDays: _cookieAgeDays,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Collection or profile URL',
                      hintText: 'https://www.tiktok.com/@user/collection/…',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    minLines: 1,
                    enabled: !_loading,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _canFetch ? _fetchLinks : null,
                    icon: const Icon(Icons.link),
                    label: const Text('Fetch Links'),
                  ),
                  const SizedBox(height: 8),
                  if (_cookieStatus == CookieStatus.expired ||
                      _cookieStatus == CookieStatus.missing)
                    OutlinedButton.icon(
                      onPressed: _reimportCookie,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Import / Re-import Cookie'),
                    ),
                  if (_loading)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _ProgressIndicator(stream: _python.linkProgressStream, initial: _progress),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _videos.isEmpty
                  ? Center(
                      child: Text(
                        _loading ? '' : 'No videos yet. Fetch a collection to begin.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _videos.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) => _VideoTile(video: _videos[i]),
                    ),
            ),
            if (_videos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${_videos.length} videos fetched',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.stream, this.initial});

  final Stream<String> stream;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        final msg = snapshot.data ?? initial ?? 'Working…';
        return Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video});

  final TikTokVideo video;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 56,
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: video.thumbnail.isEmpty
              ? _placeholder()
              : Image.network(
                  video.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                ),
        ),
      ),
      title: Text(
        video.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(video.durationLabel),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey.shade800,
        child: const Icon(Icons.movie_outlined, color: Colors.white54),
      );
}
