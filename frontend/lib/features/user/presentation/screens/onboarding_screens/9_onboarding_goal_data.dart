import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnbboardingGoalData extends StatefulWidget {
  final Function(DateTime startDate, DateTime targetDate, double targetWeight, double tempo) setGoalData;
  final DateTime? initialStartDate;
  final DateTime? initialTargetDate;
  final double? initialTargetWeight;
  final double? initialTempo;
  final double? currentWeight;

  const OnbboardingGoalData({
    super.key,
    required this.setGoalData,
    this.initialStartDate,
    this.initialTargetDate,
    this.initialTargetWeight,
    this.initialTempo,
    this.currentWeight,
  });

  @override
  State<OnbboardingGoalData> createState() => _OnbboardingGoalDataState();
}

class _OnbboardingGoalDataState extends State<OnbboardingGoalData> {
  late DateTime _startDate;
  DateTime? _targetDate;
  late double _targetWeight;
  late double _tempo;
  late double _weightDifference;

  final Map<double, String> _tempoLabels = {
    0.25: 'Very Slow (0.25 kg/week)',
    0.5: 'Standard (0.5 kg/week)',
    0.75: 'Moderate (0.75 kg/week)',
    1.0: 'Fast (1.0 kg/week)',
  };

  @override
  void initState() {
    super.initState();

    _startDate = widget.initialStartDate ?? DateTime.now();
    _targetDate = widget.initialTargetDate;
    _targetWeight =
        widget.initialTargetWeight ?? (widget.currentWeight != null ? widget.currentWeight! - 10 : 70.0);
    _tempo = widget.initialTempo ?? 0.5;
    _weightDifference = (widget.currentWeight ?? 80.0) - _targetWeight;

    if (widget.currentWeight != null) {
      _calculateTargetDate();
    }
  }

  void _calculateTargetDate() {
    if (widget.currentWeight == null) return;

    final weightDifference = (widget.currentWeight! - _targetWeight);

    setState(() {
      _weightDifference = weightDifference;
    });

    if (_tempo == 0) {
      setState(() {
        _targetDate = null;
      });
      return;
    }

    final weeksNeeded = (weightDifference.abs() / _tempo).ceil();

    setState(() {
      _targetDate = _startDate.add(Duration(days: weeksNeeded * 7));
    });
    AppLogger.debug(
      "Weight difference: $weightDifference kg, Weeks needed: $weeksNeeded, Target date: $_targetDate",
    );
  }

  Future<void> _pickTargetDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate.add(const Duration(days: 1)), // Min: jutro
      lastDate: _startDate.add(const Duration(days: 365 * 2)), // Max: 2 lata
    );

    if (pickedDate != null) {
      setState(() {
        _targetDate = pickedDate;
      });
      AppLogger.debug("Manual target date selected: $_targetDate");
    }
  }

  String _getTempoLabel() {
    return _tempoLabels[_tempo] ?? 'Custom';
  }

  @override
  Widget build(BuildContext context) {
    final currentWeight = widget.currentWeight ?? 80.0;
    final weeksNeeded = _targetDate != null ? _targetDate!.difference(_startDate).inDays ~/ 7 : 0;

    final isMaintenanceMode = _weightDifference.abs() < 0.1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    const Text('Set your goal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Define your target weight and pace',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 40),

                    const Text('Target Weight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              '${currentWeight.toStringAsFixed(1)} kg',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.grey),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Target', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              '${_targetWeight.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.blue,
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: Colors.blue,
                        overlayColor: Colors.blue.withOpacity(0.2),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      ),
                      child: Slider(
                        value: _targetWeight,
                        min: 40.0,
                        max: 150.0,
                        divisions: 220,
                        label: '${_targetWeight.toStringAsFixed(1)} kg',
                        onChanged: (value) {
                          setState(() {
                            _targetWeight = value;
                            _calculateTargetDate();
                          });
                        },
                      ),
                    ),

                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isMaintenanceMode
                              ? 'Maintenance (${_targetWeight.toStringAsFixed(1)} kg)'
                              : '${_weightDifference > 0 ? "-" : "+"}${_weightDifference.abs().toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isMaintenanceMode
                                ? Colors.blue
                                : (_weightDifference > 0 ? Colors.green : Colors.orange),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    if (!isMaintenanceMode) ...[
                      const Text(
                        'Weight Change Pace',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          _getTempoLabel(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.blue,
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: Colors.blue,
                          overlayColor: Colors.blue.withOpacity(0.2),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: _tempo,
                          min: 0.25,
                          max: 1.0,
                          divisions: 3,
                          label: _getTempoLabel(),
                          onChanged: (value) {
                            setState(() {
                              _tempo = value;
                              _calculateTargetDate();
                            });
                          },
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Slow', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('Fast', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],

                    if (isMaintenanceMode) ...[
                      const Text(
                        'Maintenance Duration',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'How long do you want to maintain this weight?',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: _pickTargetDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    _targetDate != null
                                        ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                                        : 'Select end date',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Goal Summary',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),

                          _summaryRow(
                            Icons.calendar_today,
                            'Start Date',
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          ),
                          const SizedBox(height: 12),

                          _summaryRow(
                            Icons.flag,
                            'Target Date',
                            _targetDate != null
                                ? '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'
                                : 'Not set',
                          ),
                          const SizedBox(height: 12),

                          _summaryRow(Icons.timeline, 'Duration', '$weeksNeeded weeks'),

                          if (!isMaintenanceMode) ...[
                            const SizedBox(height: 12),
                            _summaryRow(Icons.speed, 'Weekly Change', '${_tempo.toStringAsFixed(2)} kg/week'),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: OnboardingButton(
                text: 'Next',
                onPressed: _targetDate == null
                    ? () {}
                    : () {
                        widget.setGoalData(_startDate, _targetDate!, _targetWeight, _tempo);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
