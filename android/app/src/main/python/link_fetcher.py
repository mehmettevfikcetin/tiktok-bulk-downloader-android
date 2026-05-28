import urllib.request

import yt_dlp


_TIKTOK_HOSTS = ('tiktok.com', 'vm.tiktok.com', 'vt.tiktok.com')
_SHORT_HOSTS = ('vt.tiktok.com', 'vm.tiktok.com')
_USER_AGENT = (
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
)
_TIKTOK_API_HOSTNAME = 'api22-normal-c-useast2a.tiktokv.com'


def validate_url(url):
    if not url:
        return False
    u = url.strip().lower()
    return any(h in u for h in _TIKTOK_HOSTS)


def fetch_collection_links(collection_url, cookie_path, ffmpeg_path, progress_callback=None):
    def _emit(msg):
        if progress_callback is None:
            return
        try:
            progress_callback.report(msg)
        except Exception:
            pass

    _emit("Connecting to TikTok…")

    if _is_short_url(collection_url):
        _emit("Resolving short URL…")
        expanded = _expand_short_url(collection_url)
        if expanded and expanded != collection_url:
            collection_url = expanded

    opts = {
        'extract_flat': True,
        'skip_download': True,
        'quiet': True,
        'no_warnings': True,
        'ignoreerrors': True,
        'cache_dir': False,
        'socket_timeout': 30,
        'retries': 10,
        'fragment_retries': 10,
        'extractor_retries': 5,
        'sleep_interval_requests': 1.5,
        'sleep_interval': 1,
        'http_headers': {
            'User-Agent': _USER_AGENT,
            'Referer': 'https://www.tiktok.com/',
        },
        'extractor_args': {
            'tiktok': {'api_hostname': [_TIKTOK_API_HOSTNAME]},
        },
    }
    if cookie_path:
        opts['cookiefile'] = cookie_path
    if ffmpeg_path:
        opts['ffmpeg_location'] = ffmpeg_path

    try:
        with yt_dlp.YoutubeDL(opts) as ydl:
            _emit("Extracting playlist…")
            info = ydl.extract_info(collection_url, download=False)
    except yt_dlp.utils.DownloadError as e:
        raise _classify(str(e))
    except Exception as e:
        raise RuntimeError("Unexpected error: {}".format(e))

    entries = (info or {}).get('entries') or []
    total = len(entries)
    if total == 0:
        # A single video URL resolves to a video dict (no playlist entries).
        # Return it as a one-item list so it still downloads, tagged so the UI
        # can show a friendly "this is a single video" notice instead of error.
        if info and info.get('_type') != 'playlist' and (
            info.get('id') or info.get('webpage_url')
        ):
            single = {
                'id': info.get('id') or '',
                'title': info.get('title') or info.get('id') or 'Untitled',
                'url': info.get('webpage_url') or collection_url,
                'thumbnail': _pick_thumbnail(info),
                'duration': int(info.get('duration') or 0),
                'single': 'true',
            }
            _emit("Done — 1 video")
            return [single]
        raise RuntimeError("No videos found at this URL.")

    results = []
    for i, entry in enumerate(entries, 1):
        if entry is None:
            continue
        results.append({
            'id': entry.get('id') or '',
            'title': entry.get('title') or entry.get('id') or 'Untitled',
            'url': entry.get('url') or entry.get('webpage_url') or '',
            'thumbnail': _pick_thumbnail(entry),
            'duration': int(entry.get('duration') or 0),
        })
        if i % 5 == 0 or i == total:
            _emit("Parsed {} of {}".format(i, total))

    _emit("Done — {} videos".format(len(results)))
    return results


def _is_short_url(url):
    if not url:
        return False
    u = url.strip().lower()
    return any(host in u for host in _SHORT_HOSTS)


def _expand_short_url(url):
    try:
        req = urllib.request.Request(
            url,
            headers={
                'User-Agent': _USER_AGENT,
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            },
        )
        # urlopen follows redirects by default; geturl() returns the final URL.
        with urllib.request.urlopen(req, timeout=15) as resp:
            return resp.geturl()
    except Exception:
        return None


def _pick_thumbnail(entry):
    t = entry.get('thumbnail')
    if t:
        return t
    thumbs = entry.get('thumbnails') or []
    if thumbs:
        return thumbs[-1].get('url') or ''
    return ''


def _classify(msg):
    low = msg.lower()
    if 'cookie' in low:
        return RuntimeError("Cookie file invalid or expired — please re-import.")
    if '403' in low or 'private' in low:
        return RuntimeError("Login or access error — check cookies and URL.")
    if 'unable to extract' in low:
        return RuntimeError("Could not extract links — URL may be wrong or TikTok changed its API.")
    trimmed = msg if len(msg) <= 300 else msg[:300] + '…'
    return RuntimeError("yt-dlp error: {}".format(trimmed))
