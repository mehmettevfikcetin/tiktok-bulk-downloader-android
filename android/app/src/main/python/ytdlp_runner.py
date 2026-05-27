import os
from typing import Optional

import yt_dlp


_ffmpeg_location: Optional[str] = None
_cookie_path: Optional[str] = None


def get_ytdlp_version() -> str:
    return yt_dlp.version.__version__


def set_ffmpeg_location(path: str) -> str:
    global _ffmpeg_location
    _ffmpeg_location = path
    return path


def set_cookie_path(path: str) -> str:
    global _cookie_path
    _cookie_path = path
    return path


def test_download(url: str, output_dir: str) -> str:
    os.makedirs(output_dir, exist_ok=True)

    captured = {"path": None}

    def hook(d):
        if d.get("status") == "finished":
            info = d.get("info_dict") or {}
            captured["path"] = (
                info.get("_filename") or d.get("filename")
            )

    opts = {
        "outtmpl": os.path.join(output_dir, "%(id)s.%(ext)s"),
        "ffmpeg_location": _ffmpeg_location,
        "noplaylist": True,
        "progress_hooks": [hook],
        "quiet": True,
        "no_warnings": True,
        "merge_output_format": "mp4",
    }
    if _cookie_path:
        opts["cookiefile"] = _cookie_path

    with yt_dlp.YoutubeDL(opts) as ydl:
        info = ydl.extract_info(url, download=True)
        requested = ydl.prepare_filename(info)
        base, _ = os.path.splitext(requested)
        merged = base + ".mp4"
        if os.path.exists(merged):
            return merged
        if captured["path"] and os.path.exists(captured["path"]):
            return captured["path"]
        return requested


def fetch_links(url, progress_callback=None):
    from link_fetcher import fetch_collection_links
    return fetch_collection_links(url, _cookie_path, _ffmpeg_location, progress_callback)


def start_queue(
    videos_json,
    output_dir,
    ids_file_path,
    progress_callback,
    queue_callback,
    cancel_check,
    storage_helper,
):
    """Entry point for DownloadService — runs synchronously in the caller's thread.

    `videos_json` is a JSON-encoded list of `{id, url, title}` objects. We
    parse it here so that downstream code sees real Python dicts instead of
    Chaquopy Java-Map proxies (which break isinstance(entry, dict)).
    """
    import json
    videos = json.loads(videos_json) if videos_json else []
    from downloader import process_queue
    return process_queue(
        videos_list=videos,
        output_dir=output_dir,
        cookie_path=_cookie_path,
        ffmpeg_path=_ffmpeg_location,
        ids_file_path=ids_file_path,
        progress_callback=progress_callback,
        queue_callback=queue_callback,
        cancel_check=cancel_check,
        storage_helper=storage_helper,
    )
