class UserEntity {
  int? id;
  String uid;
  String email;
  String? username;
  DateTime? birthday;
  String? sex;
  int? height;
  DateTime createdAt;
  DateTime lastModifiedAt;
  String? dietType;
  Map<String, dynamic>? macroSplit;
  String? activityLevel;
  bool setupCompleted;

  UserEntity({
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
    if ((now.month < birthday!.month) || (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }
}
