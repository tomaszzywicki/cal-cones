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

  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _diffController = TextEditingController();
  bool _isEditingTarget = false;
  bool _isEditingDiff = false;
  final FocusNode _targetFocus = FocusNode();
  final FocusNode _diffFocus = FocusNode();

  final double _minTempo = 0.05;
  final double _maxTempo = 1.2;

  late double _sliderMinWeight;
  late double _sliderMaxWeight;

  @override
  void initState() {
    super.initState();
    _sliderMinWeight = widget.currentWeight - 15.0;
    _sliderMaxWeight = widget.currentWeight + 15.0;
    _targetWeight = _roundDouble(widget.currentWeight.clamp(_sliderMinWeight, _sliderMaxWeight), 1);
    _targetWeightController.text = _targetWeight.toStringAsFixed(1);
    _diffController.text = "0.0";
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
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 24.0),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(flex: 3, fit: FlexFit.tight, child: _buildTargetWeightCard()),
                          const SizedBox(height: 12),
                          Flexible(flex: 2, fit: FlexFit.tight, child: _buildWeeklyPaceCard()),
                          const SizedBox(height: 12),
                          Flexible(flex: 2, fit: FlexFit.tight, child: _buildSummaryCard()),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildBottomActionArea(),
        ],
      ),
    );
  }

  Widget _buildTargetWeightCard() {
    final bool isWeightLoss = _targetWeight < widget.currentWeight;
    final double weightDiff = (widget.currentWeight - _targetWeight).abs();

    const weightStyle = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      color: Colors.black,
      letterSpacing: -1,
    );

    return _buildSectionContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "TARGET WEIGHT",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
          _buildTargetWeightInput(weightStyle),
          _buildEditableDiffBadge(isWeightLoss, weightDiff),
          SizedBox(
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomPaint(
                    size: const Size(double.infinity, 30),
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
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
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
                Text("-15", style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _targetWeight = widget.currentWeight;
                      _calculateDate();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      "Current: ${widget.currentWeight.toStringAsFixed(1)} kg",
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                  ),
                ),
                Text("+15", style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTargetSubmit(String val) {
    double parsedWeight = double.tryParse(val.replaceAll(',', '.')) ?? _targetWeight;

    // Walidacja zakresu suwaka, aby uniknąć błędu z obrazka
    if (parsedWeight < _sliderMinWeight) parsedWeight = _sliderMinWeight;
    if (parsedWeight > _sliderMaxWeight) parsedWeight = _sliderMaxWeight;

    setState(() {
      _targetWeight = _roundDouble(parsedWeight, 1);
      _targetWeightController.text = _targetWeight.toStringAsFixed(1);
      _isEditingTarget = false;
      _calculateDate();
    });
    FocusScope.of(context).unfocus();
  }

  void _handleDiffSubmit(String val, bool isWeightLoss) {
    final diff = double.tryParse(val.replaceAll(',', '.')) ?? 0;
    double newTarget;

    if (isWeightLoss) {
      newTarget = widget.currentWeight - diff;
    } else {
      newTarget = widget.currentWeight + diff;
    }

    // Walidacja zakresu suwaka
    if (newTarget < _sliderMinWeight) newTarget = _sliderMinWeight;
    if (newTarget > _sliderMaxWeight) newTarget = _sliderMaxWeight;

    setState(() {
      _targetWeight = _roundDouble(newTarget, 1);
      _targetWeightController.text = _targetWeight.toStringAsFixed(1);
      _isEditingDiff = false;
      _calculateDate();
    });
    FocusScope.of(context).unfocus();
  }

  Widget _buildTargetWeightInput(TextStyle weightStyle) {
    return IntrinsicWidth(
      child: TextField(
        controller: _targetWeightController,
        focusNode: _targetFocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        autofocus: true,
        style: weightStyle,
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          isDense: true,
          contentPadding: EdgeInsets.zero,
          suffixText: " kg",
          suffixStyle: weightStyle.copyWith(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        onSubmitted: _handleTargetSubmit,
        onTapOutside: (_) => _handleTargetSubmit(_targetWeightController.text),
      ),
    );
  }

  Widget _buildEditableDiffBadge(bool isWeightLoss, double weightDiff) {
    Color baseColor = weightDiff < 0.1 ? Colors.grey : (isWeightLoss ? Colors.green : Colors.blue);

    return GestureDetector(
      onTap: () {
        setState(() {
          _diffController.text = weightDiff.toStringAsFixed(1);
          _isEditingDiff = true;
        });
        _diffFocus.requestFocus();
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isEditingDiff ? baseColor.withOpacity(0.5) : baseColor.withOpacity(0.15),
            // width: _isEditingDiff ? 1.5 : 1,
            width: 1,
          ),
        ),
        child: _isEditingDiff
            ? TextField(
                controller: _diffController,
                focusNode: _diffFocus,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                autofocus: true,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: baseColor.withOpacity(0.8).withRed(baseColor.red),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  prefixText: weightDiff < 0.1 ? "" : (isWeightLoss ? "-" : "+"),
                  suffixText: " kg",
                ),
                onSubmitted: (val) => _handleDiffSubmit(val, isWeightLoss),
                onTapOutside: (_) => _handleDiffSubmit(_diffController.text, isWeightLoss),
              )
            : Text(
                weightDiff < 0.1
                    ? "Maintenance"
                    : "${isWeightLoss ? '-' : '+'}${weightDiff.toStringAsFixed(1)} kg",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: weightDiff < 0.1
                      ? Colors.grey.shade700
                      : (isWeightLoss ? Colors.green.shade700 : Colors.blue.shade700),
                ),
              ),
      ),
    );
  }

  Widget _buildWeeklyPaceCard() {
    final bool isGain = _targetWeight > widget.currentWeight;
    final IconData iconType;
    final String title;
    final String message;
    final MaterialColor color;

    if (isGain) {
      if (_tempo > 0.6) {
        iconType = Icons.warning_amber_rounded;
        title = "Risky pace";
        message = "Fat build-up more prominent than muscle gain.";
        color = Colors.red;
      } else if (_tempo > 0.3) {
        iconType = Icons.warning_amber_rounded;
        title = "Fast pace";
        message = "High chance of fat build-up along with muscle gain.";
        color = Colors.orange;
      } else {
        iconType = Icons.check_circle_rounded;
        title = "Safe pace";
        message = "Optimal for muscle gain with minimal fat build-up.";
        color = Colors.blue;
      }
    } else {
      if (_tempo > 0.6) {
        iconType = Icons.warning_amber_rounded;
        title = "Fast pace";
        message = "Increased risk of muscle loss and nutrient deficiencies.";
        color = Colors.orange;
      } else {
        iconType = Icons.check_circle_rounded;
        title = "Safe pace";
        message = "Reduction achievable with minimal muscle loss.";
        color = Colors.green;
      }
    }

    return _buildSectionContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 90,
                  height: 60,
                  child: TempoGauge(tempo: _tempo, minTempo: _minTempo, maxTempo: _maxTempo, size: 10.0),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "WEEKLY PACE",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      "${_tempo.toStringAsFixed(2)} kg",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                    Text(
                      _tempo <= 0.3 ? "Sustainable" : (_tempo > 0.6 ? "Aggressive" : "Moderate"),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                _buildTempoInfoCard(iconType, title, message, color),
              ],
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.0,
              activeTrackColor: Colors.blueGrey.shade800,
              inactiveTrackColor: Colors.blueGrey.shade100,
              thumbColor: Colors.blueGrey.shade900,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            ),
            child: Slider(
              value: _tempo,
              min: _minTempo,
              max: _maxTempo,
              divisions: 23,
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
    );
  }

  Widget _buildTempoInfoCard(IconData iconType, String title, String message, MaterialColor color) {
    return Container(
      width: 94,
      constraints: const BoxConstraints(minHeight: 66),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(iconType, color: color.shade700, size: 14),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(color: color.shade800, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(color: color.shade700, fontSize: 8, fontWeight: FontWeight.w500, height: 1.1),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final int daysDuration = _estimatedDate?.difference(DateTime.now()).inDays ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWeightInfo("START", "${widget.currentWeight}", "kg"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.arrow_forward_rounded, color: Colors.blueGrey.shade300, size: 18),
              ),
              _buildWeightInfo("Target", _targetWeight.toStringAsFixed(1), "kg", isTarget: true),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                Container(height: 20, width: 1, color: Colors.blueGrey.shade100),
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
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WARNING",
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "By setting a new goal, your current goal will be closed. This change is irreversible. Record your current weight first as it has influence on both your current and new goal. ",
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value, Color iconColor, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 8, color: Colors.blueGrey.shade400, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
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
            fontSize: 9,
            color: Colors.blueGrey.shade400,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
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
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade400),
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
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final Paint mainTickPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double centerX = width / 2;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      Paint()
        ..color = Colors.blueGrey.withOpacity(0.1)
        ..strokeWidth = 1.5,
    );

    const int totalSteps = 30;
    for (int i = 0; i <= totalSteps; i++) {
      final double x = (i / totalSteps) * width;
      if (i % 5 == 0) {
        canvas.drawLine(Offset(x, size.height / 2 - 5), Offset(x, size.height / 2 + 5), mainTickPaint);
      } else {
        canvas.drawLine(Offset(x, size.height / 2 - 2), Offset(x, size.height / 2 + 2), smallTickPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SliderScalePainter oldDelegate) => false;
}
