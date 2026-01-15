import 'dart:ui';
import 'dart:math';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/goal/data/daily_target_model.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/user/data/user_model.dart';

class DailyTargetCalculatorService {
  DailyTargetModel calculateDailyTarget(UserModel user, GoalModel goal, double currentWeight) {
    if (user.id == null) {
      throw Exception('User ID is null. Cannot calculate daily target.');
    }
    if (user.height == null || user.ageYears == null || user.sex == null) {
      throw Exception('User data incomplete for BMR calculation. Cannot calculate daily target.');
    }

    double s = (user.sex == 'male') ? 5.0 : -161.0;
    double bmr = (10 * currentWeight) + (6.25 * user.height!) - (5 * user.ageYears!) + s;

    double activityFactor = _getActivityFactor(user.activityLevel);
    double tdee = bmr * activityFactor;

    const double costToBuildMusclePerKg = 7000; // kcal
    const double costToBuildFatPerKg = 8000; // kcal
    const double energyInKgFatLoss = 7700; // kcal
    const double maxMuscleGainPerWeek = 0.25; // kg

    double muscleGain;
    double fatGain;
    double fatLoss;
    if (goal.tempo > maxMuscleGainPerWeek) {
      muscleGain = maxMuscleGainPerWeek;
      fatGain = goal.tempo - maxMuscleGainPerWeek;
    } else {
      muscleGain = max(0, goal.tempo);
      fatGain = 0;
    }
    fatLoss = min(0, goal.tempo);

    double weeklyCalorieAdjustment =
        ((muscleGain * costToBuildMusclePerKg) +
        (fatGain * costToBuildFatPerKg) -
        (fatLoss.abs() * energyInKgFatLoss));

    double dailyCalorieAdjustment = weeklyCalorieAdjustment / 7.0;
    int targetCalories = (tdee + dailyCalorieAdjustment).round();

    final macroTargets = _getMacroTargets(user.dietType, targetCalories);

    return DailyTargetModel(
      date: DateTime.now().toUtc().toIso8601String().split('T').first,
      userId: user.id!,
      goalId: goal.id!,
      weightUsed: currentWeight,
      calories: targetCalories,
      proteinG: macroTargets['proteinG']!,
      carbsG: macroTargets['carbsG']!,
      fatG: macroTargets['fatG']!,
      dietType: user.dietType ?? 'balanced',
      lastModifiedAt: DateTime.now().toUtc(),
    );
  }

  double _getActivityFactor(String? activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return 1.2;
      case 'moderately_active':
        return 1.55;
      case 'very_active':
        return 1.8;
      default:
        return 1.2;
    }
  }

  Map<String, int> _getMacroTargets(String? dietType, int calories) {
    int proteinG;
    int carbsG;
    int fatG;

    // macro ratios
    double protein;
    double carbs;
    double fat;

    switch (dietType) {
      case 'high_protein':
        protein = 0.4;
        carbs = 0.3;
        fat = 0.3;
        break;
      case 'low_carb':
        protein = 0.4;
        carbs = 0.2;
        fat = 0.4;
        break;
      default:
        protein = 0.3;
        carbs = 0.4;
        fat = 0.3;
    }

    proteinG = ((calories * protein) / 4).round();
    carbsG = ((calories * carbs) / 4).round();
    fatG = ((calories * fat) / 9).round();
    return {'proteinG': proteinG, 'carbsG': carbsG, 'fatG': fatG};
  }
}
