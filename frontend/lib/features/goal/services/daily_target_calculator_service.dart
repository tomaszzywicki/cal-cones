import 'dart:math';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/goal/data/daily_target_model.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/user/data/user_model.dart';

class DailyTargetCalculatorService {
  DailyTargetModel calculateDailyTarget(UserModel user, GoalModel goal, double currentWeight) {
    int ageYears = user.ageYears ?? 30;
    String sex = user.sex?.toLowerCase() ?? 'male';
    int height = user.height ?? (sex == 'male' ? 175 : 160);
    String activityLevel = user.activityLevel?.toLowerCase() ?? 'moderately_active';
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

    const double costToBuildMusclePerKg = 1800; // kcal
    const double costToBuildFatPerKg = 8000; // kcal
    const double energyInKgMuscleLoss = 1200; // kcal
    const double energyInKgFatLoss = 7700; // kcal

    // The assumption is that:
    //   - muscle gain from 0.0 to 0.2 kg/week does not result in fat gain.
    //   - muscle gain from 0.2 to 0.5 kg/week results in some fat gain. Linearly growing from 0 fat gain at 0.2 muscle gain to 0.5 fat gain at 0.5 muscle gain.
    //   - muscle gain above 0.5 kg/week is not realistic and should be capped. Any extra tempo above 0.5 kg/week is considered as fat gain.
    //
    //   - calorie surplus induces greater non-exercise activity thermogenesis and food-induced thermogenesis, burning some of the excess calories, so we assume that not all surplus calories result in body mass gain.
    //   - based on [Slater_2019], we assume that up to 200 kcal of surplus gets burned through increased thermogenesis when in a calorie surplus.
    //   - It follows logically though that greater surplus will induce greater thermogenesis.
    //   - It would also be unrealistic to assume that more than 50% of surplus calories get burned through thermogenesis.
    //   - Therefore, we agreed on a model where 100% of surplus calories up to 200 kcal get added, which increases the final surplus
    //
    //   - weight loss up to 0.9 kg/week does not result in muscle loss. [Garthe_2011] shows that athletes were able to lose up to ~0.9 kg/week while preserving muscle mass with proper nutrition and training.
    //   - weight loss above 0.9 kg/week results in both fat loss and muscle loss. Base fat loss is 0.9 kg/week. Any extra tempo above 0.9 kg/week is divided between fat and muscle loss equally.

    const double lowerMuscleGainThreshold = 0.2; // kg
    const double upperMuscleGainThreshold = 0.5; // kg
    const double fatGainAtLowerThreshold = 0.0; // kg
    const double fatGainAtUpperThreshold = 0.5; // kg

    const double calorieSurplusThermogenesisThreshold = 200.0; // kcal

    const double safeWeightLossThreshold = 0.9; // kg

    double muscleGain;
    double muscleLoss;
    double fatGain;
    double fatLoss;
    double signedTempo = goal.isWeightLoss ? -goal.tempo : goal.tempo;

    if (signedTempo > upperMuscleGainThreshold + fatGainAtUpperThreshold) {
      muscleGain = upperMuscleGainThreshold;
      fatGain = signedTempo - upperMuscleGainThreshold;
      muscleLoss = 0;
      fatLoss = 0;
    } else if (signedTempo >= lowerMuscleGainThreshold) {
      muscleGain =
          (signedTempo - lowerMuscleGainThreshold) *
              (upperMuscleGainThreshold - lowerMuscleGainThreshold) /
              (upperMuscleGainThreshold +
                  fatGainAtUpperThreshold -
                  lowerMuscleGainThreshold -
                  fatGainAtLowerThreshold) +
          lowerMuscleGainThreshold;
      fatGain = (signedTempo - muscleGain);
      muscleLoss = 0;
      fatLoss = 0;
    } else if (signedTempo >= 0) {
      muscleGain = signedTempo;
      fatGain = 0;
      muscleLoss = 0;
      fatLoss = 0;
    } else if (signedTempo >= -safeWeightLossThreshold) {
      muscleGain = 0;
      fatGain = 0;
      muscleLoss = 0;
      fatLoss = -signedTempo;
    } else {
      muscleGain = 0;
      fatGain = 0;
      muscleLoss = (-signedTempo - safeWeightLossThreshold) / 2.0;
      fatLoss = safeWeightLossThreshold + muscleLoss;
    }
    muscleGain = double.parse(muscleGain.toStringAsFixed(3));
    fatGain = double.parse(fatGain.toStringAsFixed(3));
    muscleLoss = double.parse(muscleLoss.toStringAsFixed(3));
    fatLoss = double.parse(fatLoss.toStringAsFixed(3));
    AppLogger.info(
      'Calculated weekly body composition changes:\n\tMuscle Gain: $muscleGain kg\n\tFat Gain: $fatGain kg\n\tMuscle Loss: $muscleLoss kg\n\tFat Loss: $fatLoss kg',
    );

    double weeklyCalorieAdjustment =
        ((muscleGain * costToBuildMusclePerKg) +
        (fatGain * costToBuildFatPerKg) -
        (muscleLoss * energyInKgMuscleLoss) -
        (fatLoss * energyInKgFatLoss));

    double dailyCalorieAdjustment = weeklyCalorieAdjustment / 7.0;
    if (dailyCalorieAdjustment > 0) {
      dailyCalorieAdjustment += min(dailyCalorieAdjustment, calorieSurplusThermogenesisThreshold);
    }
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
      case 'lightly_active':
        return 1.4;
      case 'moderately_active':
        return 1.55;
      case 'very_active':
        return 1.8;
      case 'super_active':
        return 2.2;
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
