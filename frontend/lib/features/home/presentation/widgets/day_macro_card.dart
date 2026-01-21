import 'package:flutter/material.dart';
import 'package:frontend/features/meal_log/presentation/widgets/macro_line.dart';

class DayMacroCard extends StatelessWidget {
  final double consumedKcal;
  final double consumedCarbs;
  final double consumedProtein;
  final double consumedFat;
  final double targetKcal;
  final double targetCarbs;
  final double targetProtein;
  final double targetFat;
  final bool onboardingComplete;

  const DayMacroCard({
    super.key,
    required this.consumedKcal,
    required this.consumedCarbs,
    required this.consumedProtein,
    required this.consumedFat,
    this.targetKcal = 2500,
    this.targetCarbs = 200,
    this.targetProtein = 160,
    this.targetFat = 90,
    this.onboardingComplete = false,
  });

  double get remainingKcal => (targetKcal - consumedKcal).clamp(0, targetKcal);
  double get percentKcal => (consumedKcal / targetKcal).clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Sekcja kalorii
          Row(
            children: [
              // Remaining
              Expanded(
                child: _buildStatColumn(
                  value: remainingKcal.round().toString(),
                  label: 'Remaining',
                  color: Colors.grey[600]!,
                ),
              ),
              SizedBox(width: 10),

              // Circular Progress (Consumed)
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[200],
                        color: Colors.grey[200],
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: percentKcal,
                        strokeWidth: 10,
                        backgroundColor: Colors.transparent,
                        color: _getCalorieColor(),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Center text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          consumedKcal.round().toString(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Consumed',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10),

              // Target
              Expanded(
                child: _buildStatColumn(
                  value: targetKcal.round().toString(),
                  label: 'Target',
                  color: Colors.grey[600]!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Divider
          Divider(color: Colors.grey[200], thickness: 1),

          const SizedBox(height: 16),

          // Sekcja makro
          Row(
            children: [
              Expanded(
                child: MacroLine(
                  name: 'Carbs',
                  color: const Color(0xFF4CAF50), // Green
                  value: consumedCarbs,
                  endValue: targetCarbs,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MacroLine(
                  name: 'Protein',
                  color: const Color.fromARGB(255, 219, 22, 22), // Red
                  value: consumedProtein,
                  endValue: targetProtein,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MacroLine(
                  name: 'Fat',
                  color: const Color(0xFFFFC107), // Yellow
                  value: consumedFat,
                  endValue: targetFat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({required String value, required String label, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getCalorieColor() {
    return const Color.fromARGB(255, 46, 119, 255);
  }
}
