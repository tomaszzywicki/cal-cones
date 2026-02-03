import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
// Dodano import ekranu wagi
import 'package:frontend/features/weight_log/presentation/screens/weight_log_main_screen.dart';
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

  // Funkcja do zmiany wzrostu
  void _showEditHeightDialog(BuildContext context, int? currentHeight) {
    final TextEditingController controller = TextEditingController(text: currentHeight?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Height"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Height",
              suffixText: "cm",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            FilledButton(
              onPressed: () {
                final newHeight = int.tryParse(controller.text);
                if (newHeight != null && newHeight > 50 && newHeight < 300) {
                  // TODO: Tutaj wywołaj swój serwis do aktualizacji użytkownika
                  // np. context.read<UserApiService>().updateHeight(newHeight);

                  // Na razie tylko logujemy dla sprawdzenia
                  AppLogger.info("New height entered: $newHeight");
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
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
        child: isExpanded
            ? _buildexpandedview(context, bmi, user?.height, weightLogService.latestEntry?.weight)
            : _buildcompactview(context, bmi),
      ),
    );
  }

  Widget _buildexpandedview(BuildContext context, double? bmi, int? height, double? weight) {
    final hasData = bmi != null;
    final displayBmi = hasData ? bmi.toStringAsFixed(1) : "?";
    final categoryText = hasData ? _getBMICategory(bmi) : "Track your weight to see BMI";
    final displayColor = hasData ? _getBMIColor(bmi) : Colors.grey;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
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

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),

        // --- NOWE PRZYCISKI ---
        _buildInfoButton(
          context: context,
          title: "Weight",
          value: weight != null ? "${weight.toStringAsFixed(1)} kg" : "-- kg",
          icon: Icons.monitor_weight_outlined,
          onTap: () {
            // Przekierowanie do ekranu wagi
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WeightLogMainScreen()));
          },
        ),
        const SizedBox(height: 8),
        _buildInfoButton(
          context: context,
          title: "Height",
          value: height != null ? "$height cm" : "-- cm",
          icon: Icons.height,
          onTap: () {
            // Edycja wzrostu
            _showEditHeightDialog(context, height);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Pomocniczy widget do budowania przycisków
  Widget _buildInfoButton({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
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
    final points = [15.0, 18.5, 25.0, 30.0, 40.0];
    const double minBMI = 15.0;
    const double maxBMI = 40.0;

    return SizedBox(
      height: 15,
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
