"""TikTok bulk downloader — Android port.

Faithful port of DownloaderThread from reference/tiktok_downloader.py
(lines 484-656). Anti-bot delays, retry counts, yt-dlp flags, and
filename template are preserved verbatim.
"""

import json
import os
import re
import time

import yt_dlp


MAX_DOWNLOAD_RETRIES = 2
RETRY_DELAY_SECONDS = 3
INTER_VIDEO_DELAY = 2.0
SKIP_MICRO_DELAY = 0.05

USER_AGENT = (
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
)
TIKTOK_API_HOSTNAME = 'api22-normal-c-useast2a.tiktokv.com'

_ID_FROM_URL_RE = re.compile(r'/video/(\d+)')
_ID_FROM_FILENAME_RE = re.compile(r'_(\d+)\.mp4$')


def extract_id_from_url(url):
    if not url:
        return None
    m = _ID_FROM_URL_RE.search(url)
    return m.group(1) if m else None


def extract_id_from_filename(filename):
    if not filename:
        return None
    m = _ID_FROM_FILENAME_RE.search(filename)
    return m.group(1) if m else None


def load_downloaded_ids(ids_file_path):
    ids = set()
    if not ids_file_path or not os.path.exists(ids_file_path):
        return ids
    try:
        with open(ids_file_path, 'r', encoding='utf-8') as f:
            for line in f:
                vid = line.strip()
                if vid:
                    ids.add(vid)
    except Exception:
        pass
    return ids


def save_downloaded_id(ids_file_path, video_id):
    if not ids_file_path or not video_id:
        return
    try:
        os.makedirs(os.path.dirname(ids_file_path), exist_ok=True)
        with open(ids_file_path, 'a', encoding='utf-8') as f:
            f.write(video_id + '\n')
    except Exception:
        pass


def _is_cancelled(cancel_check):
    """Robust against `cancel_check` being None, a Kotlin object with
    `is_cancelled()`, or a plain Python callable."""
    if cancel_check is None:
        return False
    try:
        fn = getattr(cancel_check, 'is_cancelled', None)
        if fn is not None:
            return bool(fn())
        return bool(cancel_check())
    except Exception:
        return False


def _is_tiktok(url):
    if not url:
        return False
    u = url.lower()
    return 'tiktok.com' in u or 'vm.tiktok' in u


def _emit(callback, payload):
    """Serialize payload to JSON and hand it to a Kotlin reporter.

    Chaquopy does not auto-convert Python dicts to java.util.Map when the
    receiving parameter is typed loosely; a JSON string is unambiguous on
    both sides.
    """
    if callback is None:
        return
    try:
        callback.report(json.dumps(payload, default=str))
    except Exception:
        pass


def _interruptible_sleep(seconds, cancel_check):
    """Sleep up to `seconds`, waking every 200ms to check for cancellation."""
    if seconds <= 0:
        return
    end = time.time() + seconds
    while True:
        remaining = end - time.time()
        if remaining <= 0:
            return
        if _is_cancelled(cancel_check):
            return
        time.sleep(min(0.2, remaining))


def _build_ydl_opts(cookie_path, ffmpeg_path, output_dir, progress_hook, is_tiktok):
    # Template matches reference line 543: "%(title).30s_%(id)s.%(ext)s"
    outtmpl = os.path.join(output_dir, '%(title).30s_%(id)s.%(ext)s')
    opts = {
        'outtmpl': outtmpl,
        'format': 'bv*+ba/b[ext=mp4]/b',
        'merge_output_format': 'mp4',
        'fixup': 'force',
        'postprocessor_args': {'ffmpeg': ['-avoid_negative_ts', 'make_zero']},
        'overwrites': False,
        'noplaylist': True,
        'quiet': True,
        'no_warnings': True,
        'ignoreerrors': False,  # we handle errors ourselves so retry logic kicks in
        'retries': 5,
        'fragment_retries': 5,
        'extractor_retries': 3,
        'socket_timeout': 30,
        'cache_dir': False,
        'http_headers': {
            'User-Agent': USER_AGENT,
            'Referer': 'https://www.tiktok.com/',
        },
        'progress_hooks': [progress_hook] if progress_hook else [],
    }
    if cookie_path:
        opts['cookiefile'] = cookie_path
    if ffmpeg_path:
        opts['ffmpeg_location'] = ffmpeg_path
    if is_tiktok:
        opts['extractor_args'] = {
            'tiktok': {'api_hostname': [TIKTOK_API_HOSTNAME]},
        }
    return opts


def _is_extraction_error(message):
    if not message:
        return False
    low = message.lower()
    return 'unable to extract' in low or 'webpage video data' in low


def _friendly_extraction_error(original):
    trimmed = original[:200] if original else ''
    return (
        "TikTok video data could not be extracted. This usually means yt-dlp "
        "is outdated or the cookie file is invalid/expired.\n"
        "Fix: 1) Update the app (newer yt-dlp bundled)\n"
        "     2) Re-import a fresh cookie file from your browser\n"
        f"Original error: {trimmed}"
    )


def download_video(
    video_url,
    video_id,
    output_dir,
    cookie_path,
    ffmpeg_path,
    index,
    total,
    title,
    progress_callback,
    cancel_check,
):
    """Download a single video with the reference's retry semantics.

    Returns dict: {'status', 'file_path', 'error'}.
    """
    os.makedirs(output_dir, exist_ok=True)
    is_tiktok = _is_tiktok(video_url)
    last_error = "Unknown error"
    captured = {'path': None}

    def _hook(d):
        if _is_cancelled(cancel_check):
            raise _CancelledError()

        status = d.get('status')
        if status == 'downloading':
            total_bytes = d.get('total_bytes') or d.get('total_bytes_estimate') or 0
            downloaded = d.get('downloaded_bytes') or 0
            percent = 0
            if total_bytes > 0:
                percent = int(downloaded * 100 / total_bytes)
                if percent > 100:
                    percent = 100
            _emit(progress_callback, {
                'videoId': video_id or '',
                'index': index,
                'total': total,
                'percent': percent,
                'status': 'downloading',
                'error': None,
                'title': title or '',
            })
        elif status == 'finished':
            info = d.get('info_dict') or {}
            captured['path'] = info.get('_filename') or d.get('filename')

    for attempt in range(MAX_DOWNLOAD_RETRIES + 1):
        if _is_cancelled(cancel_check):
            return {'status': 'cancelled', 'file_path': None, 'error': None}
        try:
            opts = _build_ydl_opts(cookie_path, ffmpeg_path, output_dir, _hook, is_tiktok)
            with yt_dlp.YoutubeDL(opts) as ydl:
                info = ydl.extract_info(video_url, download=True)
                requested = ydl.prepare_filename(info)
                base, _ = os.path.splitext(requested)
                merged = base + '.mp4'
                file_path = None
                if os.path.exists(merged):
                    file_path = merged
                elif captured['path'] and os.path.exists(captured['path']):
                    file_path = captured['path']
                else:
                    file_path = requested if os.path.exists(requested) else None

            if file_path:
                return {'status': 'completed', 'file_path': file_path, 'error': None}
            last_error = "File not found after download"
        except _CancelledError:
            return {'status': 'cancelled', 'file_path': None, 'error': None}
        except yt_dlp.utils.DownloadError as e:
            last_error = str(e)
            if _is_extraction_error(last_error) and attempt < MAX_DOWNLOAD_RETRIES:
                _interruptible_sleep(RETRY_DELAY_SECONDS, cancel_check)
                continue
            if _is_extraction_error(last_error):
                last_error = _friendly_extraction_error(last_error)
            break
        except Exception as e:  # noqa: BLE001 — match reference behaviour
            last_error = str(e)
            if attempt < MAX_DOWNLOAD_RETRIES:
                _interruptible_sleep(RETRY_DELAY_SECONDS, cancel_check)
                continue
            break

    return {'status': 'error', 'file_path': None, 'error': last_error}


def process_queue(
    videos_list,
    output_dir,
    cookie_path,
    ffmpeg_path,
    ids_file_path,
    progress_callback,
    queue_callback,
    cancel_check,
    storage_helper,
):
    """Mirror of DownloaderThread.run() (ref lines 515-653).

    `storage_helper` is a Kotlin object exposing:
        copy_to_media_store(cache_file_path, display_name) -> str | None
    Called after each successful download to move the file from the app
    cache into the public Downloads/TikTok Downloader/ folder.
    """
    os.makedirs(output_dir, exist_ok=True)
    existing_ids = load_downloaded_ids(ids_file_path)
    total = len(videos_list)
    stats = {'completed': 0, 'skipped': 0, 'errors': 0, 'cancelled': 0}

    for i, entry in enumerate(videos_list):
        if _is_cancelled(cancel_check):
            stats['cancelled'] = total - i
            break

        url = (entry.get('url') or '') if entry else ''
        title = (entry.get('title') or '') if entry else ''
        entry_id = (entry.get('id') or '') if entry else ''
        video_id = entry_id or extract_id_from_url(url) or ''

        _emit(queue_callback, {
            'videoId': video_id,
            'index': i,
            'total': total,
            'percent': 0,
            'status': 'downloading',
            'error': None,
            'title': title,
        })

        if video_id and video_id in existing_ids:
            stats['skipped'] += 1
            _emit(progress_callback, {
                'videoId': video_id,
                'index': i,
                'total': total,
                'percent': 100,
                'status': 'skipped',
                'error': None,
                'title': title,
            })
            time.sleep(SKIP_MICRO_DELAY)
            continue

        result = download_video(
            video_url=url,
            video_id=video_id,
            output_dir=output_dir,
            cookie_path=cookie_path,
            ffmpeg_path=ffmpeg_path,
            index=i,
            total=total,
            title=title,
            progress_callback=progress_callback,
            cancel_check=cancel_check,
        )

        status = result.get('status')
        cache_path = result.get('file_path')

        if status == 'completed' and cache_path:
            display_name = os.path.basename(cache_path)
            moved_uri = None
            try:
                if storage_helper is not None:
                    moved_uri = storage_helper.copy_to_media_store(cache_path, display_name)
            except Exception as e:  # noqa: BLE001
                stats['errors'] += 1
                _cleanup_cache(cache_path)
                _emit(progress_callback, {
                    'videoId': video_id,
                    'index': i,
                    'total': total,
                    'percent': 0,
                    'status': 'error',
                    'error': "Could not save to Downloads: {}".format(e),
                    'title': title,
                })
                _interruptible_sleep(INTER_VIDEO_DELAY, cancel_check)
                continue

            _cleanup_cache(cache_path)
            stats['completed'] += 1
            if video_id:
                save_downloaded_id(ids_file_path, video_id)
                existing_ids.add(video_id)
            _emit(progress_callback, {
                'videoId': video_id,
                'index': i,
                'total': total,
                'percent': 100,
                'status': 'completed',
                'error': None,
                'title': title,
            })
        elif status == 'cancelled':
            _cleanup_cache(cache_path)
            stats['cancelled'] = total - i
            _emit(progress_callback, {
                'videoId': video_id,
                'index': i,
                'total': total,
                'percent': 0,
                'status': 'cancelled',
                'error': None,
                'title': title,
            })
            break
        else:
            _cleanup_cache(cache_path)
            stats['errors'] += 1
            _emit(progress_callback, {
                'videoId': video_id,
                'index': i,
                'total': total,
                'percent': 0,
                'status': 'error',
                'error': result.get('error') or 'Unknown error',
                'title': title,
            })

        _interruptible_sleep(INTER_VIDEO_DELAY, cancel_check)

    _emit(queue_callback, {
        'videoId': '',
        'index': total,
        'total': total,
        'percent': 100,
        'status': 'queue_finished',
        'error': None,
        'title': '',
        'completed': stats['completed'],
        'skipped': stats['skipped'],
        'errors': stats['errors'],
        'cancelled': stats['cancelled'],
    })

    return stats


def _cleanup_cache(path):
    if not path:
        return
    try:
        if os.path.exists(path):
            os.remove(path)
    except Exception:
        pass


class _CancelledError(Exception):
    pass
