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
      macroSplit: json['macro_split'] as Map<String, int>?,
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
}
