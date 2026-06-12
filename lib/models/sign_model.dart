class Sign {
  final String id;
  final String name;
  final String description;
  final String category;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String? videoUrl;
  final List<String> keywords;

  Sign({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.difficulty = 'easy',
    this.videoUrl,
    this.keywords = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'videoUrl': videoUrl,
      'keywords': keywords,
    };
  }

  factory Sign.fromMap(Map<String, dynamic> map) {
    return Sign(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'easy',
      videoUrl: map['videoUrl'],
      keywords: List<String>.from(map['keywords'] ?? []),
    );
  }
}
