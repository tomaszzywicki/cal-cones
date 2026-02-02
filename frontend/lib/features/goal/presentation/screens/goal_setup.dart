import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/goal/services/goal_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';
import 'package:frontend/features/goal/presentation/widgets/tempo_gauge.dart';

class GoalSetupScreen extends StatefulWidget {
  final double currentWeight;
  final bool isReplacingExistingGoal;

  const GoalSetupScreen({super.key, required this.currentWeight, this.isReplacingExistingGoal = false});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  late double _targetWeight;
  late double _tempo;
  DateTime? _estimatedDate;
  bool _isLoading = false;

  final double _minTempo = 0.05;
  final double _maxTempo = 1.2;

  late double _sliderMinWeight;
  late double _sliderMaxWeight;

  @override
  void initState() {
    super.initState();
    _sliderMinWeight = widget.currentWeight - 15.0;
    _sliderMaxWeight = widget.currentWeight + 15.0;

    // 1. Wyjściowa waga równa currentWeight
    _targetWeight = _roundDouble(widget.currentWeight.clamp(_sliderMinWeight, _sliderMaxWeight), 1);

    _tempo = 0.2;
    _calculateDate();
  }

  void _calculateDate() {
    final double rawDiff = (widget.currentWeight - _targetWeight).abs();
    final double diff = _roundDouble(rawDiff, 1);

    if (diff < 0.1 || _tempo <= 0.05) {
      setState(() => _estimatedDate = DateTime.now().add(const Duration(days: 30)));
      return;
    }

    final weeksNeeded = diff / _tempo;
    final daysNeeded = (weeksNeeded * 7).round();

    setState(() {
      _estimatedDate = DateTime.now().add(Duration(days: daysNeeded));
    });
  }

  Future<void> _saveGoal() async {
    setState(() => _isLoading = true);
    try {
      final userId = context.read<CurrentUserService>().getUserId();
      final newGoal = GoalModel(
        userId: userId,
        startDate: DateTime.now(),
        targetDate: _estimatedDate!,
        startWeight: widget.currentWeight,
        targetWeight: _targetWeight,
        tempo: _tempo,
        isCurrent: true,
      );

      await context.read<GoalService>().setNewGoal(newGoal, closedGoalFinalWeight: widget.currentWeight);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeightLoss = _targetWeight < widget.currentWeight;
    final double weightDiff = (widget.currentWeight - _targetWeight).abs();
    final int daysDuration = _estimatedDate?.difference(DateTime.now()).inDays ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Goal Setup",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24.0, // uwzględnienie paddingu vertical
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. TARGET WEIGHT CARD
                          _buildSectionContainer(
                            child: Column(
                              children: [
                                const Text(
                                  "TARGET WEIGHT",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      _targetWeight.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "kg",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 2, bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: weightDiff == 0
                                        ? Colors.grey.shade100
                                        : (isWeightLoss ? Colors.green.shade50 : Colors.blue.shade50),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    weightDiff == 0
                                        ? "Maintenance"
                                        : "${isWeightLoss ? '-' : '+'}${weightDiff.toStringAsFixed(1)} kg",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: weightDiff == 0
                                          ? Colors.grey.shade700
                                          : (isWeightLoss ? Colors.green.shade700 : Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 45,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: CustomPaint(
                                          size: const Size(double.infinity, 35),
                                          painter: _SliderScalePainter(
                                            min: _sliderMinWeight,
                                            max: _sliderMaxWeight,
                                            centerValue: widget.currentWeight,
                                          ),
                                        ),
                                      ),
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 2.0,
                                          activeTrackColor: Colors.black,
                                          inactiveTrackColor: Colors.transparent,
                                          thumbColor: Colors.black,
                                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                                        ),
                                        child: Slider(
                                          value: _targetWeight,
                                          min: _sliderMinWeight,
                                          max: _sliderMaxWeight,
                                          onChanged: (val) {
                                            setState(() {
                                              _targetWeight = _roundDouble(val, 1);
                                              _calculateDate();
                                            });
                                            HapticFeedback.selectionClick();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "-15",
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                                      ),
                                      Text(
                                        "Current",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        "+15",
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 2. WEEKLY PACE CARD
                          _buildSectionContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        height: 45,
                                        child: TempoGauge(
                                          tempo: _tempo,
                                          minTempo: _minTempo,
                                          maxTempo: _maxTempo,
                                          size: 70,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "WEEKLY PACE",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          Text(
                                            "${_tempo.toStringAsFixed(2)} kg",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            _tempo < 0.4
                                                ? "Sustainable"
                                                : (_tempo > 0.9 ? "Aggressive" : "Moderate"),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3.0,
                                    activeTrackColor: Colors.blueGrey.shade800,
                                    inactiveTrackColor: Colors.blueGrey.shade100,
                                    thumbColor: Colors.blueGrey.shade900,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                  ),
                                  child: Slider(
                                    value: _tempo,
                                    min: _minTempo,
                                    max: _maxTempo,
                                    divisions: 22,
                                    onChanged: (val) {
                                      setState(() {
                                        _tempo = _roundDouble(val, 2);
                                        _calculateDate();
                                      });
                                      HapticFeedback.selectionClick();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 3. SUMMARY CARD
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blueGrey.shade100),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildWeightInfo("START", "${widget.currentWeight}", "kg"),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.blueGrey.shade300,
                                        size: 20,
                                      ),
                                    ),
                                    _buildWeightInfo(
                                      "Target",
                                      _targetWeight.toStringAsFixed(1),
                                      "kg",
                                      isTarget: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueGrey.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildSummaryItem(
                                        Icons.timer_outlined,
                                        "DURATION",
                                        "$daysDuration days",
                                        Colors.blueGrey.shade400,
                                        Colors.blueGrey.shade800,
                                      ),
                                      Container(height: 25, width: 1, color: Colors.blueGrey.shade100),
                                      _buildSummaryItem(
                                        Icons.event_available_outlined,
                                        "ESTIMATED FINISH",
                                        DateFormat('MMM d, yyyy').format(_estimatedDate!),
                                        Colors.blue.shade300,
                                        Colors.blue.shade800,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- BOTTOM ACTIONS CONTAINER ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isReplacingExistingGoal) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "WARNING",
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "By setting a new goal, your current goal will be closed. This change is irreversible. Make sure to record your current weight as a closing weight for the old goal.",
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : OnboardingButton(
                          text: widget.isReplacingExistingGoal ? "Close Old & Start New" : "Start Goal",
                          onPressed: _saveGoal,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value, Color iconColor, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 9, color: Colors.blueGrey.shade400, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildWeightInfo(String label, String value, String unit, {bool isTarget = false}) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: Colors.blueGrey.shade400,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: isTarget ? FontWeight.w900 : FontWeight.bold,
                color: isTarget ? Colors.black : Colors.blueGrey.shade600,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade400),
            ),
          ],
        ),
      ],
    );
  }

  double _roundDouble(double value, int places) {
    final mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
}

class _SliderScalePainter extends CustomPainter {
  final double min;
  final double max;
  final double centerValue;

  _SliderScalePainter({required this.min, required this.max, required this.centerValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final Paint smallTickPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final Paint mainTickPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final double centerX = width / 2;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      Paint()
        ..color = Colors.blueGrey.withOpacity(0.1)
        ..strokeWidth = 2,
    );

    const int totalSteps = 30;
    for (int i = 0; i <= totalSteps; i++) {
      final double x = (i / totalSteps) * width;
      final bool isMainTick = i % 5 == 0;

      if (isMainTick) {
        const double tickHeight = 12.0;
        canvas.drawLine(
          Offset(x, size.height / 2 - tickHeight / 2),
          Offset(x, size.height / 2 + tickHeight / 2),
          mainTickPaint,
        );
      } else {
        const double tickHeight = 6.0;
        canvas.drawLine(
          Offset(x, size.height / 2 - tickHeight / 2),
          Offset(x, size.height / 2 + tickHeight / 2),
          smallTickPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SliderScalePainter oldDelegate) => false;
}
