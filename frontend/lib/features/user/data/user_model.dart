import 'package:frontend/features/user/data/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    super.id,
    required super.uid,
    required super.email,
    super.username,
    super.birthday,
    super.sex,
    super.height,
    required super.createdAt,
    required super.lastModifiedAt,
    super.dietType,
    super.macroSplit,
    super.activityLevel,
    required super.setupCompleted,
  });

  // Backend API response parsing
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      uid: json['uid'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday'] as String) : null,
      sex: json['sex'] as String?,
      height: json['height'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['last_modified_at'] as String),
      dietType: json['diet_type'] as String?,
      macroSplit: json['macro_split'] as Map<String, dynamic>?,
      activityLevel: json['activity_level'] as String?,
      setupCompleted: json['setup_completed'] as bool,
    );
  }

  // UserModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'username': username,
      'birthday': birthday,
      'sex': sex,
      'height': height,
      'created_at': createdAt,
      'last_modified_at': lastModifiedAt,
      'diet_type': dietType,
      'macro_split': macroSplit,
      'activity_level': activityLevel,
      'setup_completed': setupCompleted,
    };
  }

  // UserModel to Map for local db inserts
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'username': username,
      'birthday': birthday?.toIso8601String(),
      'sex': sex,
      'height': height,
      'created_at': createdAt.toIso8601String(),
      'last_modified_at': lastModifiedAt.toIso8601String(),
      'diet_type': dietType,
      'macro_split': macroSplit,
      'activity_level': activityLevel,
      'setup_completed': setupCompleted,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      uid: map['uid'] as String,
      email: map['email'] as String,
      username: map['username'] as String?,
      birthday: map['birthday'] != null ? DateTime.parse(map['birthday'] as String) : null,
      sex: map['sex'] as String?,
      height: map['height'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastModifiedAt: DateTime.parse(map['last_modified_at'] as String),
      dietType: map['diet_type'] as String?,
      macroSplit: map['macro_split'] as Map<String, dynamic>?,
      activityLevel: map['activity_level'] as String?,
      setupCompleted: map['setup_completed'] as bool,
    );
  }

  int? get ageYears {
    if (birthday == null) return null;
    final today = DateTime.now();
    int age = today.year - birthday!.year;
    if (today.month < birthday!.month || (today.month == birthday!.month && today.day < birthday!.day)) {
      age--;
    }
    return age;
  }
}
