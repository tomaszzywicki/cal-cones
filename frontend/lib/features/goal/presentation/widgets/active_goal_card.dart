import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';

class ActiveGoalCard extends StatefulWidget {
  final GoalModel goal;

  const ActiveGoalCard({super.key, required this.goal});

  @override
  State<ActiveGoalCard> createState() => _ActiveGoalCardState();
}

class _ActiveGoalCardState extends State<ActiveGoalCard> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Access current weight
    final weightLogService = context.watch<WeightLogService>();
    final double currentWeight = weightLogService.latestEntry?.weight ?? widget.goal.startWeight;

    // --- CALCULATIONS ---
    final now = DateTime.now();

    // 1. Time progress
    final totalDays = widget.goal.targetDate.difference(widget.goal.startDate).inDays;
    final daysElapsed = now.difference(widget.goal.startDate).inDays;
    final daysRemaining = widget.goal.targetDate.difference(now).inDays;

    double timeProgress = 0.0;
    if (totalDays > 0) {
      timeProgress = (daysElapsed / totalDays).clamp(0.0, 1.0);
    }

    // 2. Weight progress & Difference Logic
    final double start = widget.goal.startWeight;
    final double target = widget.goal.targetWeight;
    double weightProgress = 0.0;
    if ((start - target).abs() > 0) {
      weightProgress = ((start - currentWeight) / (start - target)).clamp(0.0, 1.0);
    }

    // Difference from Start
    final double difference = currentWeight - start;

    // Determine if "Good" or "Bad" direction
    // If start > target (Weight Loss): Negative difference is GOOD (Green)
    // If start < target (Weight Gain): Positive difference is GOOD (Green)
    final bool isWeightLossGoal = start > target;
    final bool isGoodProgress = isWeightLossGoal ? difference <= 0 : difference >= 0;

    // Colors
    Color weightColor = weightProgress >= 1.0 ? const Color(0xFF43A047) : const Color(0xFF4CAF50);
    Color waveColor = const Color(0xFF1976D2).withOpacity(0.7);

    // Difference Text Formatting
    String diffSign = difference > 0 ? '+' : '';
    Color diffColor = isGoodProgress ? const Color(0xFF43A047) : const Color(0xFFE53935); // Green or Red

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      child: Container(
        constraints: const BoxConstraints(minHeight: 380), // Taller card
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Active Goal",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    daysRemaining > 0 ? "$daysRemaining days left" : "Time's up",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- CURRENT WEIGHT & DIFFERENCE (CENTER) ---
            Column(
              children: [
                const Text(
                  "CURRENT WEIGHT",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                // Big Weight Number
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currentWeight.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        letterSpacing: -2.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "kg",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
                // Difference (Green/Red)
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Text(
                    "($diffSign${difference.toStringAsFixed(1)} kg)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: diffColor),
                  ),
                ),
              ],
            ),

            // FIXED: Replaced Spacer() with SizedBox to avoid unbounded height error
            const SizedBox(height: 40),

            // --- TEMPO VISUALIZATION (Yellow/Orange) ---
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0), // Orange 50
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFCC80), width: 1), // Orange 200
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shutter_speed, size: 20, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Text(
                      "Pace: ${widget.goal.tempo} kg/week",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24), // Space between Tempo and Bars
            // --- PROGRESS BARS SECTION ---
            Column(
              children: [
                // 1. Dates
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(widget.goal.startDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(widget.goal.targetDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Time Bar (Ocean Wave)
                SizedBox(
                  height: 14,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
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
                const SizedBox(height: 2),

                // 3. Weight Bar (Green Shimmer)
                SizedBox(
                  height: 36, // Tall enough for text
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      // Fill & Shimmer
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: weightProgress > 0 ? weightProgress : 0.001,
                                  child: Container(color: weightColor),
                                ),
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
                      // Texts on the bar
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Start: ${start.toStringAsFixed(1)}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const Icon(Icons.double_arrow_outlined, size: 20, color: Colors.black45),
                              Text(
                                "Target: ${target.toStringAsFixed(1)}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
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

// --- REUSED PAINTER ---
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

    final double waveHeight = size.height * 0.3;
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
    const double frequency = 2.0;
    return (amplitude / 2) * math.sin((x / width * frequency * 2 * math.pi) - phase) + baseY;
  }

  @override
  bool shouldRepaint(covariant OceanWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
