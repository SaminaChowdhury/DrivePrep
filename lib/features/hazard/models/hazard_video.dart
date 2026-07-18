class HazardVideo {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int durationSeconds;
  final String category;
  final int hazardTimestampSeconds;
  final int order;

  const HazardVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.category,
    required this.hazardTimestampSeconds,
    required this.order,
  });

  factory HazardVideo.fromJson(Map<String, dynamic> json) {
    return HazardVideo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 15,
      category: json['category'] as String,
      hazardTimestampSeconds: json['hazardTimestampSeconds'] as int? ?? 8,
      order: json['order'] as int? ?? 0,
    );
  }
}
