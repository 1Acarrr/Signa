class Translation {
  final String id;
  final String userId;
  final String inputType; // 'sign' or 'speech'
  final String outputText;
  final double confidenceScore;
  final DateTime createdAt;

  Translation({
    required this.id,
    required this.userId,
    required this.inputType,
    required this.outputText,
    required this.confidenceScore,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'inputType': inputType,
      'outputText': outputText,
      'confidenceScore': confidenceScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      inputType: map['inputType'] ?? 'sign',
      outputText: map['outputText'] ?? '',
      confidenceScore: (map['confidenceScore'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
