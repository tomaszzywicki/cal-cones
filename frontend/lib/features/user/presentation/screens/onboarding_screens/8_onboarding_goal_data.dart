import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';
import 'package:frontend/features/goal/presentation/widgets/tempo_gauge.dart';

class OnboardingGoalData extends StatefulWidget {
  final Function(DateTime startDate, DateTime targetDate, double targetWeight, double tempo) setGoalData;
  final DateTime? initialStartDate;
  final DateTime? initialTargetDate;
  final double? initialTargetWeight;
  final double? initialTempo;
  final double? currentWeight;

  const OnboardingGoalData({
    super.key,
    required this.setGoalData,
    this.initialStartDate,
    this.initialTargetDate,
    this.initialTargetWeight,
    this.initialTempo,
    this.currentWeight,
  });

  @override
  State<OnboardingGoalData> createState() => _OnboardingGoalDataState();
}

class _OnboardingGoalDataState extends State<OnboardingGoalData> {
  late double _targetWeight;
  late double _tempo;
  DateTime? _estimatedDate;
  DateTime? _maintenanceDate;

  // Kontrolery i FocusNode przeniesione 1:1 z GoalSetupScreen
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _diffController = TextEditingController();
  bool _isEditingDiff = false;
  final FocusNode _targetFocus = FocusNode();
  final FocusNode _diffFocus = FocusNode();

  final double _minTempo = 0.05;
  final double _maxTempo = 1.2;

  late double _sliderMinWeight;
  late double _sliderMaxWeight;

  // Logika rozpoznawania trybu maintenance
  bool get _isMaintenance => (_targetWeight - (widget.currentWeight ?? 70.0)).abs() < 0.05;

  final List<int> _presetDays = [14, 28, 60, 90, 180, 270, 365, 730];

  @override
  void initState() {
    super.initState();
    final current = widget.currentWeight ?? 70.0;
    _sliderMinWeight = current - 15.0;
    _sliderMaxWeight = current + 15.0;

    // Inicjalizacja wartościami (jeśli brak, to waga aktualna = maintenance)
    _targetWeight = _roundDouble(
      (widget.initialTargetWeight ?? current).clamp(_sliderMinWeight, _sliderMaxWeight),
      1,
    );
    _targetWeightController.text = _targetWeight.toStringAsFixed(1);

    final diff = (current - _targetWeight).abs();
    _diffController.text = diff.toStringAsFixed(1);

    _tempo = widget.initialTempo ?? 0.2;
    // Jeśli mamy initialTargetDate, używamy go, jeśli nie - domyślne 28 dni dla maintenance
    _maintenanceDate = widget.initialTargetDate ?? DateTime.now().add(const Duration(days: 29));

    _calculateDate();
  }

  void _calculateDate() {
    if (_isMaintenance) return;

    final double rawDiff = ((widget.currentWeight ?? 70.0) - _targetWeight).abs();
    final double diff = _roundDouble(rawDiff, 1);

    if (diff == 0.0 || _tempo < 0.05) {
      setState(() => _estimatedDate = DateTime.now().add(const Duration(days: 28)));
      return;
    }

    final weeksNeeded = diff / _tempo;
    final daysNeeded = (weeksNeeded * 7).round();

    setState(() {
      _estimatedDate = DateTime.now().add(Duration(days: daysNeeded));
    });
  }

  void _onNext() {
    final finalDate = _isMaintenance ? _maintenanceDate! : _estimatedDate!;
    widget.setGoalData(
      widget.initialStartDate ?? DateTime.now(),
      finalDate,
      _targetWeight,
      _isMaintenance ? 0.0 : _tempo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            const Text('Choose your goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight - 24.0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 180,
                            maxHeight: max(availableHeight * 0.30, 180),
                          ),
                          child: _buildTargetWeightCard(),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: _isMaintenance ? 220 : 170,
                            maxHeight: max(availableHeight * 0.35, _isMaintenance ? 220 : 170),
                          ),
                          child: _isMaintenance ? _buildMaintenanceDurationCard() : _buildWeeklyPaceCard(),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 160,
                            maxHeight: max(availableHeight * 0.30, 160),
                          ),
                          child: _buildSummaryCard(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Użycie OnboardingButton zamiast BottomActionArea
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: OnboardingButton(text: "Next", onPressed: _onNext),
            ),
          ],
        ),
      ),
    );
  }

  // --- IDENTYCZNE METODY UI Z GOAL_SETUP_SCREEN ---

  Widget _buildTargetWeightCard() {
    final current = widget.currentWeight ?? 70.0;
    final bool isWeightLoss = _targetWeight < current;
    final double weightDiff = (current - _targetWeight).abs();
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: CustomPaint(
                    size: const Size(double.infinity, 30),
                    painter: _SliderScalePainter(
                      min: _sliderMinWeight,
                      max: _sliderMaxWeight,
                      centerValue: current,
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
                        _targetWeightController.text = _targetWeight.toStringAsFixed(1);
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
                Text("-15", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _targetWeight = current;
                      _targetWeightController.text = current.toStringAsFixed(1);
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
                      "Current: ${current.toStringAsFixed(1)} kg",
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                  ),
                ),
                Text("+15", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetWeightInput(TextStyle weightStyle) {
    return Container(
      width: 150,
      height: 40,
      alignment: Alignment.center,
      child: TextField(
        controller: _targetWeightController,
        focusNode: _targetFocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: weightStyle,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          focusColor: Colors.transparent,
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

  void _handleTargetSubmit(String val) {
    double parsedWeight = double.tryParse(val.replaceAll(',', '.')) ?? _targetWeight;
    parsedWeight = parsedWeight.clamp(_sliderMinWeight, _sliderMaxWeight);
    setState(() {
      _targetWeight = _roundDouble(parsedWeight, 1);
      _targetWeightController.text = _targetWeight.toStringAsFixed(1);
      _calculateDate();
    });
    FocusScope.of(context).unfocus();
  }

  Widget _buildEditableDiffBadge(bool isWeightLoss, double weightDiff) {
    Color baseColor = weightDiff == 0.0 ? Colors.orange : (isWeightLoss ? Colors.green : Colors.blue);
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
        height: 30,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isEditingDiff ? baseColor.withOpacity(0.5) : baseColor.withOpacity(0.15),
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: baseColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isCollapsed: true,
                  fillColor: Colors.transparent,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  prefixText: weightDiff == 0.0 ? "" : (isWeightLoss ? "-" : "+"),
                  suffixText: " kg",
                ),
                onSubmitted: (val) => _handleDiffSubmit(val, isWeightLoss),
                onTapOutside: (_) => _handleDiffSubmit(_diffController.text, isWeightLoss),
              )
            : Text(
                weightDiff == 0.0
                    ? "Maintenance"
                    : "${isWeightLoss ? '-' : '+'}${weightDiff.toStringAsFixed(1)} kg",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: weightDiff == 0.0
                      ? Colors.orangeAccent.shade700
                      : (isWeightLoss ? Colors.green.shade700 : Colors.blue.shade700),
                ),
              ),
      ),
    );
  }

  void _handleDiffSubmit(String val, bool isWeightLoss) {
    final diff = double.tryParse(val.replaceAll(',', '.')) ?? 0;
    final current = widget.currentWeight ?? 70.0;
    double newTarget = isWeightLoss ? current - diff : current + diff;
    newTarget = newTarget.clamp(_sliderMinWeight, _sliderMaxWeight);
    setState(() {
      _targetWeight = _roundDouble(newTarget, 1);
      _targetWeightController.text = _targetWeight.toStringAsFixed(1);
      _isEditingDiff = false;
      _calculateDate();
    });
    FocusScope.of(context).unfocus();
  }

  Widget _buildWeeklyPaceCard() {
    final bool isGain = _targetWeight > (widget.currentWeight ?? 70.0);
    final IconData iconType;
    final String title;
    final String message;
    final MaterialColor color;

    if (isGain) {
      if (_tempo > 0.6) {
        iconType = Icons.warning_amber_rounded;
        title = "Risky pace";
        color = Colors.red;
        message = "Fat build-up more prominent than muscle gain.";
      } else if (_tempo > 0.3) {
        iconType = Icons.warning_amber_rounded;
        title = "Fast pace";
        color = Colors.orange;
        message = "High chance of fat build-up along with muscle gain.";
      } else {
        iconType = Icons.check_circle_rounded;
        title = "Safe pace";
        color = Colors.blue;
        message = "Optimal for muscle gain with minimal fat build-up.";
      }
    } else {
      if (_tempo > 0.6) {
        iconType = Icons.warning_amber_rounded;
        title = "Fast pace";
        color = Colors.orange;
        message = "Increased risk of muscle loss and nutrient deficiencies.";
      } else {
        iconType = Icons.check_circle_rounded;
        title = "Safe pace";
        color = Colors.green;
        message = "Reduction achievable with minimal muscle loss.";
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
                Column(
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
      constraints: const BoxConstraints(minHeight: 68),
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

  Widget _buildMaintenanceDurationCard() {
    return _buildSectionContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              const Text(
                "MAINTENANCE DURATION",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "How long do you want to maintain this weight?",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildDateOption("2 Weeks", 15),
              _buildDateOption("4 Weeks", 29),
              _buildDateOption("2 Months", 61),
              _buildDateOption("3 Months", 91),
              _buildDateOption("6 Months", 181),
              _buildDateOption("9 Months", 271),
              _buildDateOption("1 Year", 366),
              _buildDateOption("2 Years", 731),
            ],
          ),
          const SizedBox(height: 12),
          _buildCustomDatePickerButton(),
        ],
      ),
    );
  }

  Widget _buildDateOption(String label, int days) {
    final today = DateTime.now();
    final targetDate = DateTime(today.year, today.month, today.day).add(Duration(days: days));
    bool isSelected =
        _maintenanceDate != null &&
        _maintenanceDate!.year == targetDate.year &&
        _maintenanceDate!.month == targetDate.month &&
        _maintenanceDate!.day == targetDate.day;
    return GestureDetector(
      onTap: () {
        setState(() => _maintenanceDate = DateTime.now().add(Duration(days: days)));
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDatePickerButton() {
    bool isCustomSelected = true;
    final today = DateTime.now();
    for (var day in _presetDays) {
      final presetDate = DateTime(today.year, today.month, today.day).add(Duration(days: day));
      if (_maintenanceDate != null &&
          _maintenanceDate!.year == presetDate.year &&
          _maintenanceDate!.month == presetDate.month &&
          _maintenanceDate!.day == presetDate.day) {
        isCustomSelected = false;
        break;
      }
    }
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _maintenanceDate ?? DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now().add(const Duration(days: 7)),
          lastDate: DateTime.now().add(const Duration(days: 4000)),
        );
        if (picked != null) setState(() => _maintenanceDate = picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isCustomSelected ? Colors.black : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCustomSelected ? Colors.black : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: isCustomSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMM d, yyyy').format(_maintenanceDate!),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isCustomSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final displayDate = _isMaintenance ? _maintenanceDate! : (_estimatedDate ?? DateTime.now());
    final int daysDuration = displayDate.difference(DateTime.now()).inDays;

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
          _buildGoalSummaryHeader(),
          const SizedBox(height: 12),
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
                  DateFormat('MMM d, yyyy').format(displayDate),
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

  Widget _buildGoalSummaryHeader() {
    final current = widget.currentWeight ?? 70.0;
    final bool isGain = _targetWeight > current;
    Color goalColor = _isMaintenance
        ? Colors.orange.shade700
        : (isGain ? Colors.blue.shade700 : Colors.green.shade700);
    String goalActionText = _isMaintenance ? "MAINTAIN WEIGHT OF" : (isGain ? "GAIN WEIGHT" : "LOSE WEIGHT");

    return Column(
      children: [
        const Text(
          "YOUR NEW GOAL",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: goalColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                goalActionText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: goalColor,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _isMaintenance
                ? Text(
                    "${current.toStringAsFixed(1)} kg",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWeightInfo("START", current.toStringAsFixed(1), "kg"),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Icon(Icons.arrow_forward_rounded, color: goalColor.withOpacity(0.5), size: 20),
                      ),
                      _buildWeightInfo(
                        "TARGET",
                        _targetWeight.toStringAsFixed(1),
                        "kg",
                        isTarget: true,
                        targetColor: goalColor,
                      ),
                    ],
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

  Widget _buildWeightInfo(
    String label,
    String value,
    String unit, {
    bool isTarget = false,
    Color? targetColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 8, color: Colors.blueGrey.shade400, fontWeight: FontWeight.bold),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isTarget ? FontWeight.w900 : FontWeight.bold,
                color: isTarget ? (targetColor ?? Colors.black) : Colors.blueGrey.shade600,
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
