import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class BMIcard extends StatelessWidget {
  final bool isExpanded;

  const BMIcard({super.key, this.isExpanded = false});

  double _calculateBMI(double weight, int heightCm) {
    final heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal weight';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obesity';
    }
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 25) {
      return Colors.green;
    } else if (bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserService>().currentUser;
    final weightLogService = context.watch<WeightLogService>();

    double? bmi;
    if (user != null && user.height != null && weightLogService.latestEntry != null) {
      bmi = _calculateBMI(weightLogService.latestEntry!.weight, user.height!);
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isExpanded ? _buildexpandedview(context, bmi) : _buildcompactview(context, bmi),
      ),
    );
  }

  Widget _buildexpandedview(BuildContext context, double? bmi) {
    final hasData = bmi != null;
    final displayBmi = hasData ? bmi.toStringAsFixed(1) : "?";
    final categoryText = hasData ? _getBMICategory(bmi) : "Track your weight to see BMI";
    final displayColor = hasData ? _getBMIColor(bmi) : Colors.grey;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Text(
          "Your BMI Score",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          displayBmi,
          style: Theme.of(
            context,
          ).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold, color: displayColor),
        ),
        Text(
          categoryText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: hasData ? Colors.grey[700] : Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        _buildBMIGauge(context, bmi),
      ],
    );
  }

  Widget _buildcompactview(BuildContext context, double? bmi) {
    final hasData = bmi != null;
    final displayBmi = hasData ? bmi.toStringAsFixed(1) : "?";
    final categoryText = hasData ? _getBMICategory(bmi) : "Track your weight to see BMI";
    final displayColor = hasData ? _getBMIColor(bmi) : Colors.grey;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "BMI Score",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    categoryText,
                    style: TextStyle(
                      color: displayColor,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              displayBmi,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: displayColor,
              ),
            ),
          ],
        ),
        _buildBMIGauge(context, bmi),
      ],
    );
  }

  Widget _buildBMIGauge(BuildContext context, double? bmi) {
    const double minBMI = 15.0;
    const double maxBMI = 40.0;
    const double range = maxBMI - minBMI;

    const double underweightLimit = 18.5;
    const double normalLimit = 25.0;
    const double overweightLimit = 30.0;

    double normalize(double val) {
      return ((val - minBMI) / range).clamp(0.0, 1.0);
    }

    final double posUnderweight = normalize(underweightLimit);
    final double posNormal = normalize(normalLimit);
    final double posOverweight = normalize(overweightLimit);

    // Jeśli BMI jest null, nie pokazujemy strzałki, ale zachowujemy miejsce (SizedBox)
    Widget indicatorWidget;
    if (bmi != null) {
      final double posBMI = normalize(bmi);
      indicatorWidget = Align(
        alignment: Alignment(posBMI * 2 - 1, 1.0),
        child: SizedBox(
          width: 0,
          child: OverflowBox(
            minWidth: 32,
            maxWidth: 32,
            child: Transform.translate(
              offset: const Offset(0, 6),
              child: Icon(Icons.arrow_drop_down, size: 32, color: Colors.grey.shade700),
            ),
          ),
        ),
      );
    } else {
      // Pusty widget o tej samej wysokości, żeby układ "nie skakał"
      indicatorWidget = const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 28, child: indicatorWidget),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              stops: [
                0.0,
                posUnderweight,
                posUnderweight,
                posNormal,
                posNormal,
                posOverweight,
                posOverweight,
                1.0,
              ],
              colors: const [
                Colors.blue, Colors.blue, // Underweight
                Colors.green, Colors.green, // Normal
                Colors.orange, Colors.orange, // Overweight
                Colors.red, Colors.red, // Obese
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    // Lista punktów granicznych
    final points = [15.0, 18.5, 25.0, 30.0, 40.0];
    const double minBMI = 15.0;
    const double maxBMI = 40.0;

    return SizedBox(
      height: 15, // Wysokość kontenera na tekst
      child: Stack(
        children: points.map((val) {
          double normalized = (val - minBMI) / (maxBMI - minBMI);
          double alignX = (normalized * 2) - 1;

          return Align(
            alignment: Alignment(alignX, 0.0),
            child: Text(val.toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          );
        }).toList(),
      ),
    );
  }
}
