import 'dart:ui';
import 'dart:math';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/goal/data/daily_target_model.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/user/data/user_model.dart';

class DailyTargetCalculatorService {
  DailyTargetModel calculateDailyTarget(UserModel user, GoalModel goal, double currentWeight) {
    // if (user.id == null) {
    //   throw Exception('User ID is null. Cannot calculate daily target.');
    // }
    // if (user.height == null || user.ageYears == null || user.sex == null) {
    //   throw Exception('User data incomplete for BMR calculation. Cannot calculate daily target.');
    // }
    int ageYears = user.ageYears ?? 30;
    String sex = user.sex ?? 'female';
    int height = user.height ?? (sex == 'male' ? 175 : 160);
    String activityLevel = user.activityLevel ?? 'moderately_active';
    String dietType = user.dietType ?? 'low_carb';

    double s = (sex == 'male') ? 5.0 : -161.0;
    double bmr = (10 * currentWeight) + (6.25 * height) - (5 * ageYears) + s;

    double activityFactor = _getActivityFactor(activityLevel);
    double tdee = bmr * activityFactor;

    const double costToBuildMusclePerKg = 7000; // kcal
    const double costToBuildFatPerKg = 8000; // kcal
    const double energyInKgFatLoss = 7700; // kcal
    const double maxMuscleGainPerWeek = 0.25; // kg

    double muscleGain;
    double fatGain;
    double fatLoss;
    double signedTempo = goal.isWeightLoss ? -goal.tempo : goal.tempo;
    if (signedTempo > maxMuscleGainPerWeek) {
      muscleGain = maxMuscleGainPerWeek;
      fatGain = signedTempo - maxMuscleGainPerWeek;
    } else {
      muscleGain = max(0, signedTempo);
      fatGain = 0;
    }
    fatLoss = min(0, signedTempo);

    double weeklyCalorieAdjustment =
        ((muscleGain * costToBuildMusclePerKg) +
        (fatGain * costToBuildFatPerKg) -
        (fatLoss.abs() * energyInKgFatLoss));

    double dailyCalorieAdjustment = weeklyCalorieAdjustment / 7.0;
    int targetCalories = (tdee + dailyCalorieAdjustment).round();

    final macroTargets = _getMacroTargets(dietType, targetCalories);

    return DailyTargetModel(
      date: DateTime.now().toUtc().toIso8601String().split('T').first,
      userId: user.id!,
      goalId: goal.id!,
      weightUsed: currentWeight,
      calories: targetCalories,
      proteinG: macroTargets['proteinG']!,
      carbsG: macroTargets['carbsG']!,
      fatG: macroTargets['fatG']!,
      dietType: dietType,
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
