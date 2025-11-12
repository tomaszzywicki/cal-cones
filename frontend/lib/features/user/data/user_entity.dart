class UserEntity {
  final int? id;
  final String uid;
  final String email;
  final String? username;
  final DateTime? birthday;
  final String? sex;
  final int? height;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final String? dietType;
  final Map<String, int>? macroSplit;
  final String? activityLevel;
  final bool setupCompleted;

  const UserEntity({
    this.id,
    required this.uid,
    required this.email,
    this.username,
    this.birthday,
    this.sex,
    this.height,
    required this.createdAt,
    required this.lastModifiedAt,
    this.dietType,
    this.macroSplit,
    this.activityLevel,
    required this.setupCompleted,
  });

  int? get age {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if ((now.month < birthday!.month) ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }
}
