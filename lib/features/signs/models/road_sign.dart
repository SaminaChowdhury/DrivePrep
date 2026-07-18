class RoadSign {
  final String id;
  final String title;
  final String meaning;
  final String category;
  final String imageAssetPath;

  const RoadSign({
    required this.id,
    required this.title,
    required this.meaning,
    required this.category,
    required this.imageAssetPath,
  });

  factory RoadSign.fromJson(Map<String, dynamic> json) {
    return RoadSign(
      id: json['id'] as String,
      title: json['title'] as String,
      meaning: json['meaning'] as String,
      category: json['category'] as String,
      imageAssetPath: json['imageAssetPath'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'meaning': meaning,
        'category': category,
        'imageAssetPath': imageAssetPath,
      };
}
