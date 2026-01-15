import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/goal/services/goal_service.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:frontend/features/goal/data/goal_model.dart';

class CurrentGoalCard extends StatefulWidget {
  const CurrentGoalCard({super.key});

  @override
  State<CurrentGoalCard> createState() => _CurrentGoalCardState();
}

class _CurrentGoalCardState extends State<CurrentGoalCard> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Efekt światła (shimmer)
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    // Efekt fali (ocean)
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final double? currentWeight = weightLogService.latestEntry?.weight;

    return FutureBuilder<GoalModel?>(
      future: context.read<GoalService>().getActiveGoal(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            color: Colors.white,
            child: SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
          );
        }

        final activeGoal = snapshot.data;
        if (activeGoal == null) {
          return const Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text("No active goal", style: TextStyle(color: Colors.grey)),
              ),
            ),
          );
        }

        return _buildSeparatedContent(activeGoal, currentWeight ?? activeGoal.startWeight);
      },
    );
  }

  Widget _buildSeparatedContent(GoalModel goal, double currentWeight) {
    final now = DateTime.now();

    // --- 1. OBLICZENIA CZASU ---
    final totalDays = goal.targetDate.difference(goal.startDate).inDays;
    final daysElapsed = now.difference(goal.startDate).inDays;
    final daysRemaining = goal.targetDate.difference(now).inDays;

    double timeProgress = 0.0;
    if (totalDays > 0) {
      timeProgress = (daysElapsed / totalDays).clamp(0.0, 1.0);
    }

    // --- 2. OBLICZENIA WAGI ---
    final double start = goal.startWeight;
    final double target = goal.targetWeight;

    double weightProgress = 0.0;
    final totalDist = (start - target).abs();
    final coveredDist = (start - currentWeight).abs();

    bool isMovingRightWay = goal.isWeightLoss ? currentWeight <= start : currentWeight >= start;

    if (totalDist > 0 && isMovingRightWay) {
      weightProgress = (coveredDist / totalDist).clamp(0.0, 1.0);
    }

    // Kolory
    bool isGoalReached = weightProgress >= 1.0;
    Color weightColor = isMovingRightWay ? const Color(0xFF4CAF50) : const Color(0xFFE57373);
    if (isGoalReached) weightColor = const Color(0xFF43A047);

    // Kolor fali
    Color waveColor = const Color(0xFF1976D2).withOpacity(0.7);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      "CURRENTLY",
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    // Days Left
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        daysRemaining > 0 ? "$daysRemaining days left" : "Time's up",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        currentWeight.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "kg",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // const SizedBox(height: 8),

            // --- 1. PASEK CZASU (OCEAN WAVE) - GÓRNY ---
            Column(
              children: [
                SizedBox(
                  height: 8, // Wysokość paska czasu
                  child: Stack(
                    children: [
                      // Tło paska
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100.withOpacity(0.5),
                          // bottom 2 px rounded, top 4 px rounded
                          // borderRadius: BorderRadius.circular(3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(3),
                            topRight: Radius.circular(3),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                        ),
                      ),
                      // Fala
                      ClipRRect(
                        // borderRadius: BorderRadius.circular(0),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: OceanWavePainter(
                            progress: timeProgress,
                            animationValue: _waveController,
                            color: waveColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1), // Odstęp między paskami
                // --- 2. PASEK WAGI (SHIMMER) - DOLNY ---
                SizedBox(
                  height: 24, // Wysokość paska wagi (nieco grubszy)
                  child: Stack(
                    children: [
                      // Tło paska
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          // borderRadius: BorderRadius.circular(3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(3),
                            bottomRight: Radius.circular(3),
                          ),
                        ),
                      ),
                      // Pasek Postępu
                      ClipRRect(
                        // borderRadius: BorderRadius.circular(4),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                // Kolor bazowy
                                FractionallySizedBox(
                                  widthFactor: weightProgress,
                                  child: Container(color: weightColor),
                                ),
                                // Shimmer
                                if (weightProgress > 0)
                                  FractionallySizedBox(
                                    widthFactor: weightProgress,
                                    child: AnimatedBuilder(
                                      animation: _shimmerController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                            constraints.maxWidth *
                                                weightProgress *
                                                (_shimmerController.value * 2 - 1),
                                            0,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.0),
                                                  Colors.white.withOpacity(0.3),
                                                  Colors.white.withOpacity(0.0),
                                                ],
                                                stops: const [0.0, 0.5, 1.0],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Weights on bar
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            start.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      // Arrow in the middle
                      const Center(
                        child: Icon(
                          Icons.double_arrow_sharp,
                          size: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            target.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- OCEAN WAVE PAINTER ---
class OceanWavePainter extends CustomPainter {
  final double progress;
  final Animation<double> animationValue;
  final Color color;

  OceanWavePainter({required this.progress, required this.animationValue, required this.color})
    : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final double drawWidth = size.width * progress;

    // Parametry fali dla małego paska
    final double waveHeight = size.height * 0.2;
    final double waveBaseY = size.height * 0.2;

    path.moveTo(0, size.height);
    path.lineTo(0, _calculateWaveY(0, size.width, waveHeight, waveBaseY));

    for (double x = 0; x <= drawWidth; x++) {
      final double y = _calculateWaveY(x, size.width, waveHeight, waveBaseY);
      path.lineTo(x, y);
    }

    path.lineTo(drawWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  double _calculateWaveY(double x, double width, double amplitude, double baseY) {
    final double phase = animationValue.value * 2 * math.pi;
    const double frequency = 3.0; // Więcej falek
    return (amplitude / 2) * math.sin((x / width * frequency * 2 * math.pi) - phase) + baseY;
  }

  @override
  bool shouldRepaint(covariant OceanWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
