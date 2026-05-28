class TikTokVideo {
  const TikTokVideo({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnail,
    required this.duration,
    this.isSingleVideo = false,
  });

  final String id;
  final String title;
  final String url;
  final String thumbnail;
  final int duration;
  final bool isSingleVideo;

  factory TikTokVideo.fromMap(Map<dynamic, dynamic> map) {
    final rawDuration = map['duration'];
    final duration = rawDuration is num ? rawDuration.toInt() : 0;
    return TikTokVideo(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? 'Untitled').toString(),
      url: (map['url'] ?? '').toString(),
      thumbnail: (map['thumbnail'] ?? '').toString(),
      duration: duration,
      isSingleVideo: (map['single'] ?? '').toString() == 'true',
    );
  }

  String get durationLabel {
    if (duration <= 0) return '--:--';
    final m = duration ~/ 60;
    final s = duration % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
