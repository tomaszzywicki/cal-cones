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
    String sex = user.sex?.toLowerCase() ?? 'male';
    int height = user.height ?? (sex == 'male' ? 175 : 160);
    String activityLevel = user.activityLevel?.toLowerCase() ?? 'sedentary';
    String dietType = user.dietType?.toLowerCase() ?? 'balanced';

    double s = (sex == 'male') ? 5.0 : -161.0;
    double bmr = (10 * currentWeight) + (6.25 * height) - (5 * ageYears) + s;

    double activityFactor = _getActivityFactor(activityLevel);
    double tdee = bmr * activityFactor;

    AppLogger.info(
      'Calculating daily target:\n\tWeight: $currentWeight kg\n\tHeight: $height cm\n\tAge: $ageYears years\n\tSex: $sex',
    );
    AppLogger.info(
      'Activity Level: $activityLevel\nBMR: $bmr kcal\nActivity Factor: $activityFactor\nTDEE: $tdee kcal',
    );

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

    AppLogger.info(
      "Daily Calorie Adjustment: $dailyCalorieAdjustment kcal\nTarget Calories: $targetCalories kcal",
    );

    final macroTargets = _getMacroTargets(user, targetCalories);

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

  Map<String, int> _getMacroTargets(UserModel user, int calories) {
    // AppLogger.info('DEBUG: user.macroSplit content: ${user.macroSplit}');
    // AppLogger.info('DEBUG: user.macroSplit type: ${user.macroSplit.runtimeType}');

    double proteinRatio;
    double carbsRatio;
    double fatRatio;

    // 1. Próba pobrania custom splitu z user.macroSplit
    final customSplit = user.macroSplit;
    if (customSplit != null &&
        customSplit.containsKey('Protein') &&
        customSplit.containsKey('Carbs') &&
        customSplit.containsKey('Fat')) {
      proteinRatio = (customSplit['Protein'] as num).toDouble() / 100.0;
      carbsRatio = (customSplit['Carbs'] as num).toDouble() / 100.0;
      fatRatio = (customSplit['Fat'] as num).toDouble() / 100.0;

      AppLogger.info('Using custom macro split from user profile.');
    } else {
      // 2. Fallback do predefiniowanych diet, jeśli custom split nie istnieje
      switch (user.dietType?.toLowerCase()) {
        case 'high_protein':
          proteinRatio = 0.4;
          carbsRatio = 0.3;
          fatRatio = 0.3;
          break;
        case 'low_carb':
          proteinRatio = 0.4;
          carbsRatio = 0.2;
          fatRatio = 0.4;
          break;
        default:
          proteinRatio = 0.3;
          carbsRatio = 0.4;
          fatRatio = 0.3;
      }
      AppLogger.info('Using default split for diet type: ${user.dietType}');
    }

    AppLogger.info('Macro Ratios:\n\tProtein: $proteinRatio\n\tCarbs: $carbsRatio\n\tFat: $fatRatio');

    int proteinG = ((calories * proteinRatio) / 4).round();
    int carbsG = ((calories * carbsRatio) / 4).round();
    int fatG = ((calories * fatRatio) / 9).round();

    AppLogger.info(
      'Calculated Macro Targets:\n\tProtein: $proteinG g\n\tCarbs: $carbsG g\n\tFat: $fatG g\nUsing diet_type: ${user.dietType}',
    );

    return {'proteinG': proteinG, 'carbsG': carbsG, 'fatG': fatG};
  }
}
