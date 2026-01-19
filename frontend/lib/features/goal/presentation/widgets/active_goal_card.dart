import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/features/home/presentation/widgets/warning_card.dart';
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
  late AnimationController _gaugeController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();

    // Animacja wskazówki
    _gaugeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _gaugeController.forward();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _waveController.dispose();
    _gaugeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final double currentWeight = weightLogService.latestEntry?.weight ?? widget.goal.startWeight;
    final bool hasCurrentWeight = weightLogService.latestEntry?.weight != null;

    // --- CALCULATIONS ---
    final now = DateTime.now();

    // 1. Time progress
    final totalDays = widget.goal.targetDate.difference(widget.goal.startDate).inDays;
    final daysElapsed = now.difference(widget.goal.startDate).inDays;
    final daysRemaining = widget.goal.targetDate.difference(now).inDays;

    double timeProgress = 0.0;
    if (totalDays > 0) {
      // Obliczamy surowy postęp czasu
      timeProgress = (daysElapsed / totalDays);
    }

    // 2. Weight progress
    final double start = widget.goal.startWeight;
    final double target = widget.goal.targetWeight;
    double rawWeightProgress = 0.0; // Surowa wartość do logiki "czerwonego tła"

    if ((start - target).abs() > 0) {
      rawWeightProgress = (start - currentWeight) / (start - target);
    }

    // 3. Wizualne wartości (Clampowane do min 0.1, max 1.0)
    // Dzięki temu paski nigdy nie są puste, zawsze widać "początek"
    final double visualTimeProgress = timeProgress.clamp(0.1, 1.0);
    final double visualWeightProgress = rawWeightProgress.clamp(0.1, 1.0);

    // 4. Logika kolorów i tła (zapożyczona z CurrentGoalCard)
    // Jeśli postęp czasu jest większy niż postęp wagi, tło staje się czerwone
    bool isBehindSchedule = timeProgress > rawWeightProgress;

    // Kolor wypełnienia paska wagi
    bool isGoalReached = rawWeightProgress >= 1.0;
    Color weightColor = isGoalReached ? const Color(0xFF43A047) : const Color(0xFF4CAF50);

    // Kolor fali (czasu)
    Color waveColor = const Color(0xFF1976D2).withOpacity(0.7);

    // Kolor tła paska wagi (Czerwony jeśli jesteśmy w tyle, Szary jeśli ok)
    Color weightBarBackgroundColor = isBehindSchedule ? Colors.red.shade100 : Colors.grey.shade200;

    // Obliczenia różnicy wagi dla tekstu
    final double difference = currentWeight - start;
    final bool isWeightLossGoal = start > target;
    final bool isGoodProgress = isWeightLossGoal ? difference <= 0 : difference >= 0;
    String diffSign = difference > 0 ? '+' : '';
    Color diffColor = hasCurrentWeight
        ? (isGoodProgress ? const Color(0xFF43A047) : const Color(0xFFE53935))
        : Color(0xFFE53935);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      child: Container(
        constraints: const BoxConstraints(minHeight: 380),
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
                    color: isGoalReached ? Colors.green.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isGoalReached
                        ? "Completed"
                        : daysRemaining > 0
                        ? "$daysRemaining days left"
                        : "Time's up",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isGoalReached ? Colors.green.shade800 : Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- CURRENT WEIGHT & DIFFERENCE ---
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      hasCurrentWeight ? currentWeight.toStringAsFixed(1) : " ? ",
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: hasCurrentWeight ? Colors.black87 : Colors.grey,
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
                if (!hasCurrentWeight)
                  WarningCard(
                    title: "Missing Weight Data",
                    subtitle: "Log your weight to track your progress",
                    icon: Icons.monitor_weight_outlined,
                    color: Colors.red,
                    buttonText: "Log Weight",
                    buttonAction: () => Navigator.of(context).pushNamed('/weight-log'),
                    buttonUnder: true,
                  )
                else
                  Center(
                    // Dodane dla poprawnego centrowania
                    child: Transform.translate(
                      offset: const Offset(0, -6),
                      child: Text(
                        "$diffSign${difference.toStringAsFixed(1)} kg since start",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: diffColor),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 40),

            // --- TEMPO GAUGE ---
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // GAUGE
                    SizedBox(
                      width: 50,
                      height: 25,
                      child: CustomPaint(
                        painter: TempoGaugePainter(tempo: widget.goal.tempo, animation: _gaugeController),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PLANNED PACE",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          "${widget.goal.tempo} kg/week",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- PROGRESS BARS ---
            Column(
              children: [
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

                // Time Bar (Blue / Wave)
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
                            progress: visualTimeProgress, // Używamy clampowanej wartości (min 0.1)
                            animationValue: _waveController,
                            color: waveColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),

                // Weight Bar (Green / Red Background)
                SizedBox(
                  height: 36,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Tło - zmienia się na czerwone, jeśli jesteśmy w tyle
                      Container(
                        decoration: BoxDecoration(
                          color: weightBarBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                // Główny pasek postępu (min 0.1 szerokości)
                                FractionallySizedBox(
                                  widthFactor: visualWeightProgress,
                                  child: Container(color: weightColor),
                                ),
                                // Efekt Shimmer (tylko na wypełnionej części)
                                if (rawWeightProgress > 0)
                                  FractionallySizedBox(
                                    widthFactor: visualWeightProgress,
                                    child: AnimatedBuilder(
                                      animation: _shimmerController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                            constraints.maxWidth *
                                                visualWeightProgress *
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
                      // Etykiety Start / Target
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
                              const Icon(Icons.double_arrow_outlined, size: 20, color: Colors.black54),
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

// --- FIXED GAUGE PAINTER WITH MANUAL CAPS ---
class TempoGaugePainter extends CustomPainter {
  final double tempo;
  final Animation<double> animation;

  TempoGaugePainter({required this.tempo, required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    const double maxTempo = 1.2;
    final double normalizedTempo = (tempo / maxTempo).clamp(0.0, 1.0);

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final Color startColor = const Color(0xFF4CAF50);
    final Color endColor = const Color(0xFFD32F2F);

    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: [startColor, const Color(0xFFFFEB3B), const Color(0xFFFF9800), endColor],
      stops: const [0.0, 0.4, 0.7, 1.0],
    ).createShader(rect);

    final arcPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 6;

    canvas.drawArc(rect, math.pi, math.pi, false, arcPaint);

    final capRadius = 3.0;

    final startCapCenter = Offset(center.dx - radius, center.dy);
    canvas.drawCircle(startCapCenter, capRadius, Paint()..color = startColor);

    final endCapCenter = Offset(center.dx + radius, center.dy);
    canvas.drawCircle(endCapCenter, capRadius, Paint()..color = endColor);

    final currentProgress = normalizedTempo * animation.value;
    final needleAngle = math.pi + (currentProgress * math.pi);

    final needleLength = radius - 2;
    final needleX = center.dx + needleLength * math.cos(needleAngle);
    final needleY = center.dy + needleLength * math.sin(needleAngle);

    final needlePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, Offset(needleX, needleY), needlePaint);
    canvas.drawCircle(center, 4, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant TempoGaugePainter oldDelegate) {
    return oldDelegate.tempo != tempo || oldDelegate.animation != animation;
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
