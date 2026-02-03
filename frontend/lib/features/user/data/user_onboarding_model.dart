import 'package:frontend/features/user/data/user_entity.dart';

class UserOnboardingModel {
  // User Entity Part
  int id;
  String uid;
  String username;
  DateTime birthday;
  String sex;
  int height;
  String dietType;
  Map<String, int> macroSplit;
  String activityLevel;

  // Goal Entity Part
  DateTime startDate;
  DateTime targetDate;
  double startWeight;
  double targetWeight;
  double tempo; // kg/week

  UserOnboardingModel({
    required this.id,
    required this.uid,
    required this.username,
    required this.birthday,
    required this.sex,
    required this.height,
    required this.dietType,
    required this.macroSplit,
    required this.activityLevel,
    required this.startDate,
    required this.targetDate,
    required this.startWeight,
    required this.targetWeight,
    required this.tempo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'username': username,
      'birthday': birthday.toIso8601String(),
      'sex': sex,
      'height': height,
      'diet_type': dietType,
      'macro_split': macroSplit,
      'activity_level': activityLevel,
      'start_date': startDate.toIso8601String(),
      'target_date': targetDate.toIso8601String(),
      'start_weight': startWeight,
      'target_weight': targetWeight,
      'tempo': tempo,
    };
  }
}
