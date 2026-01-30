import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
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

  // Przechowujemy Future w zmiennej, aby uniknąć lagów przy animacjach
  Future<GoalModel?>? _activeGoalFuture;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ta metoda wywoła się tylko gdy GoalService wywoła notifyListeners().
    // Dzięki temu Future odświeży się tylko gdy dane faktycznie się zmienią,
    // a nie przy każdej klatce animacji fali/shimmera.
    final goalService = context.watch<GoalService>();
    _activeGoalFuture = goalService.getActiveGoal();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Słuchamy zmian wagi (rebuild przy nowym wpisie)
    final weightLogService = context.watch<WeightLogService>();
    final WeightEntryModel? latestWeightEntry = weightLogService.latestEntry;

    return FutureBuilder<GoalModel?>(
      future: _activeGoalFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return const Card(
            color: Colors.white,
            child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
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

        return _buildSeparatedContent(activeGoal, latestWeightEntry);
      },
    );
  }

  Widget _buildSeparatedContent(GoalModel goal, WeightEntryModel? latestWeightEntry) {
    final now = DateTime.now();
    final double screenWidth = MediaQuery.of(context).size.width;
    double rel(double size) => screenWidth * (size / 480.0);

    // --- 1. OBLICZENIA CZASU ---
    final totalDays = goal.targetDate.difference(goal.startDate).inDays;
    final daysElapsed = now.difference(goal.startDate).inDays;
    final daysRemaining = goal.targetDate.difference(now).inDays;

    double timeProgress = 0.0;
    if (totalDays > 0) {
      timeProgress = (daysElapsed / totalDays);
    }

    // --- 2. OBLICZENIA WAGI ---
    final double start = goal.startWeight;
    final double target = goal.targetWeight;

    final double currentWeight = latestWeightEntry?.weight ?? start;
    final String displayedCurrentWeight = latestWeightEntry?.weight.toStringAsFixed(1) ?? " ? ";
    double weightProgress = (start - currentWeight) / (start - target);

    // Kolory
    bool isGoalReached = weightProgress >= 1.0;
    Color weightColor = const Color(0xFF4CAF50);
    if (isGoalReached) weightColor = const Color(0xFF43A047);

    Color waveColor = const Color(0xFF1976D2).withOpacity(0.7);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: rel(20), right: rel(20), top: rel(8), bottom: rel(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Text(
                  "Current Goal",
                  style: TextStyle(fontSize: rel(18), fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                const Divider(thickness: 1, height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 8),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "CURRENTLY",
                            style: TextStyle(
                              fontSize: rel(10),
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isGoalReached ? Colors.green.shade50 : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isGoalReached
                                  ? "Completed"
                                  : daysRemaining > 0
                                  ? "$daysRemaining days left"
                                  : "Time's up",
                              style: TextStyle(
                                fontSize: rel(11),
                                fontWeight: FontWeight.bold,
                                color: isGoalReached ? Colors.green.shade800 : Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                displayedCurrentWeight,
                                style: TextStyle(
                                  fontSize: rel(42),
                                  fontWeight: FontWeight.w900,
                                  color: latestWeightEntry?.weight != null ? Colors.black87 : Colors.grey,
                                  letterSpacing: -1.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "kg",
                                style: TextStyle(
                                  fontSize: rel(18),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
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
            Column(
              children: [
                SizedBox(
                  height: 8,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(3),
                            topRight: Radius.circular(3),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: OceanWavePainter(
                            progress: timeProgress.clamp(0.1, 1.0),
                            animationValue: _waveController,
                            color: waveColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                SizedBox(
                  height: 24,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: timeProgress > weightProgress ? Colors.red.shade100 : Colors.grey.shade200,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(3),
                            bottomRight: Radius.circular(3),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: weightProgress.clamp(0.1, 1.0),
                                  child: Container(color: weightColor),
                                ),
                                if (weightProgress > 0)
                                  FractionallySizedBox(
                                    widthFactor: weightProgress.clamp(0.0, 1.0),
                                    child: AnimatedBuilder(
                                      animation: _shimmerController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                            constraints.maxWidth *
                                                weightProgress.clamp(0.0, 1.0) *
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              start.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: rel(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Center(child: Icon(Icons.double_arrow_outlined, size: 20, color: Colors.black54)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              target.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: rel(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
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

class OceanWavePainter extends CustomPainter {
  final double progress;
  final Animation<double> animationValue;
  final Color color;

  OceanWavePainter({required this.progress, required this.animationValue, required this.color})
    : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Path path = Path();
    final drawWidth = size.width * progress;
    final waveHeight = size.height * 0.2;
    final waveBaseY = size.height * 0.2;
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
    const double frequency = 3.0;
    return (amplitude / 2) * math.sin((x / width * frequency * 2 * math.pi) - phase) + baseY;
  }

  @override
  bool shouldRepaint(covariant OceanWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
