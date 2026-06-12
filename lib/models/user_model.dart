class User {
  final String uid;
  final String fullName;
  final String email;
  final DateTime createdAt;
  final int totalTranslations;
  final int learnedSigns;
  final double testSuccessRate;

  User({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.createdAt,
    this.totalTranslations = 0,
    this.learnedSigns = 0,
    this.testSuccessRate = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'totalTranslations': totalTranslations,
      'learnedSigns': learnedSigns,
      'testSuccessRate': testSuccessRate,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      totalTranslations: map['totalTranslations'] ?? 0,
      learnedSigns: map['learnedSigns'] ?? 0,
      testSuccessRate: (map['testSuccessRate'] ?? 0.0).toDouble(),
    );
  }
}
