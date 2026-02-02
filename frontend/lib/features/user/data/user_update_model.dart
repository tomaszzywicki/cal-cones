import 'package:frontend/features/user/data/user_model.dart';

class UserProfileModel {
  // User Entity Part
  int id;
  String username;
  DateTime birthday;
  int height;
  String dietType;
  Map<String, int> macroSplit;
  String activityLevel;

  UserProfileModel({
    required this.id,
    required this.username,
    required this.birthday,
    required this.height,
    required this.dietType,
    required this.macroSplit,
    required this.activityLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'birthday': birthday.toIso8601String(),
      'height': height,
      'diet_type': dietType,
      'macro_split': macroSplit,
      'activity_level': activityLevel,
    };
  }

  factory UserProfileModel.fromUserModel(UserModel userModel) {
    return UserProfileModel(
      id: userModel.id!,
      username: userModel.username!,
      birthday: userModel.birthday!,
      height: userModel.height!,
      dietType: userModel.dietType!,
      macroSplit: userModel.macroSplit?.cast<String, int>() ?? {},
      activityLevel: userModel.activityLevel!,
    );
  }
}
