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

  final double _minTempo = 0.1;
  final double _maxTempo = 1.2;

  late double _sliderMinWeight;
  late double _sliderMaxWeight;

  @override
  void initState() {
    super.initState();
    // Zakres suwaka: +/- 15kg od obecnej wagi
    _sliderMinWeight = widget.currentWeight - 15.0;
    _sliderMaxWeight = widget.currentWeight + 15.0;

    // Domyślny cel - zaokrąglony do 1 miejsca po przecinku
    double rawTarget = widget.currentWeight - 5.0;
    _targetWeight = _roundDouble(rawTarget.clamp(_sliderMinWeight, _sliderMaxWeight), 1);

    _tempo = 0.5;
    _calculateDate();
  }

  void _calculateDate() {
    // 1. Oblicz różnicę i zaokrąglij ją do 1 miejsca po przecinku (zgodnie z UI)
    // To eliminuje błędy typu 4.99999999 kg
    final double rawDiff = (widget.currentWeight - _targetWeight).abs();
    final double diff = _roundDouble(rawDiff, 1);

    // Zabezpieczenie przed dzieleniem przez zero lub zbyt małą różnicą
    if (diff < 0.1 || _tempo <= 0.05) {
      setState(() => _estimatedDate = DateTime.now().add(const Duration(days: 30)));
      return;
    }

    // Obliczenia
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
        id: 0,
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
          // --- SCROLLABLE CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
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
                        const SizedBox(height: 8), // Mniejszy odstęp
                        // Wyświetlacz liczbowy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _targetWeight.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ), // Mniejsza czcionka
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "kg",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ],
                        ),

                        // Badge różnicy
                        Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isWeightLoss ? Colors.green.shade50 : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${isWeightLoss ? '-' : '+'}${weightDiff.toStringAsFixed(1)} kg",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isWeightLoss ? Colors.green.shade700 : Colors.blue.shade700,
                            ),
                          ),
                        ),

                        // SUWAK Z PODZIAŁKĄ (RULER SLIDER)
                        SizedBox(
                          height: 50, // Wysokość kontenera na suwak i tło
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Warstwa 1: Podziałka i znacznik środka
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ), // Padding taki jak thumb suwaka +/-
                                child: CustomPaint(
                                  size: const Size(double.infinity, 40),
                                  painter: _SliderScalePainter(
                                    min: _sliderMinWeight,
                                    max: _sliderMaxWeight,
                                    centerValue: widget.currentWeight,
                                  ),
                                ),
                              ),

                              // Warstwa 2: Suwak
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2.0, // Cieńsza linia, żeby widać było podziałkę
                                  activeTrackColor: Colors.black,
                                  inactiveTrackColor:
                                      Colors.transparent, // Przezroczyste, widać linię z Paintera
                                  thumbColor: Colors.black,
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                ),
                                child: Slider(
                                  value: _targetWeight,
                                  min: _sliderMinWeight,
                                  max: _sliderMaxWeight,
                                  onChanged: (val) {
                                    setState(() {
                                      // Zaokrąglamy do 1 miejsca po przecinku (np. 75.4 kg)
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

                        // Opisy pod suwakiem
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("-15", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                              // Środek zaznaczony wyżej graficznie, tu tekst
                              Text(
                                "Current",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text("+15", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. WEEKLY PACE CARD
                  _buildSectionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(),
                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80, // Mniejszy Gauge
                                height: 50,
                                child: TempoGauge(
                                  tempo: _tempo,
                                  minTempo: _minTempo,
                                  maxTempo: _maxTempo,
                                  size: 80,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "WEEKLY PACE",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    "${_tempo.toStringAsFixed(2)} kg",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    _tempo < 0.4 ? "Sustainable" : (_tempo > 0.9 ? "Aggressive" : "Moderate"),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              // TODO: Fix this info box
                              // if (_targetWeight > widget.currentWeight && _tempo > 0.25)
                              //   Container(
                              //     margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                              //     padding: const EdgeInsets.all(10),
                              //     decoration: BoxDecoration(
                              //       color: Colors.orange.shade50,
                              //       borderRadius: BorderRadius.circular(10),
                              //       border: Border.all(color: Colors.orange.shade200),
                              //     ),
                              //     child: Row(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       mainAxisSize: MainAxisSize
                              //           .min, // 1. Ważne: Wiersz zajmuje tylko tyle miejsca ile musi
                              //       children: [
                              //         Icon(
                              //           Icons.info_outline_rounded,
                              //           color: Colors.orange.shade700,
                              //           size: 18,
                              //         ),
                              //         const SizedBox(width: 10),
                              //         // 2. Ważne: Flexible zamiast Expanded naprawia błąd "unbounded width"
                              //         Flexible(
                              //           child: Text(
                              //             "Pace > 0.25kg/week implies that some gained mass will likely be stored as fat.",
                              //             style: TextStyle(
                              //               color: Colors.orange.shade800,
                              //               fontSize: 11,
                              //               fontWeight: FontWeight.w600,
                              //               height: 1.3,
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

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
                                // Zaokrąglamy do 2 miejsc po przecinku (np. 0.55 kg/week)
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

                  const SizedBox(height: 16),

                  // 3. SUMMARY CARD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: Column(
                      children: [
                        // SEKCJA WAGI: Start -> Target
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildWeightInfo("START", "${widget.currentWeight}", "kg"),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.blueGrey.shade300,
                                size: 24,
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

                        const SizedBox(height: 24),

                        // SEKCJA CZASU: Duration + Date razem
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white),
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
                              // Ilość dni
                              Row(
                                children: [
                                  Icon(Icons.timer_outlined, size: 18, color: Colors.blueGrey.shade400),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DURATION",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blueGrey.shade400,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "$daysDuration days",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Pionowy separator
                              Container(height: 30, width: 1, color: Colors.blueGrey.shade100),

                              // Data końcowa
                              Row(
                                children: [
                                  Icon(Icons.event_available_outlined, size: 18, color: Colors.blue.shade300),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "ESTIMATED FINISH",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blueGrey.shade400,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMM d, yyyy').format(_estimatedDate!),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // 4. WARNING
                  if (widget.isReplacingExistingGoal)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "By setting a new goal, your current goal will be closed. Make sure to record your final weight for the old goal.",
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // --- BOTTOM BUTTON ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : OnboardingButton(
                      text: widget.isReplacingExistingGoal ? "Close Old & Start New" : "Start Goal",
                      onPressed: _saveGoal,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16), // Mniejszy padding wewnątrz karty (było 20)
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
            fontSize: 11,
            color: Colors.blueGrey.shade400,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: isTarget ? FontWeight.w900 : FontWeight.bold,
                color: isTarget ? Colors.black : Colors.blueGrey.shade600,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade400),
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

// --- PAINTER DO PODZIAŁKI I ŚRODKA ---
class _SliderScalePainter extends CustomPainter {
  final double min;
  final double max;
  final double centerValue;

  _SliderScalePainter({required this.min, required this.max, required this.centerValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;

    // Styl małej kreski (co 1 kg)
    final Paint smallTickPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Styl dużej kreski (co 5 kg: -15, -10, -5, 0, +5, +10, +15)
    final Paint mainTickPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Rysujemy linię pomocniczą przez cały środek (subtelna w tle)
    // Dzięki logice poniżej, środkowa "duża kreska" narysuje się idealnie na niej.
    final double centerX = width / 2;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      Paint()
        ..color = Colors.blueGrey
            .withOpacity(0.1) // Bardzo delikatne tło
        ..strokeWidth = 2,
    );

    // Całkowity zakres to 30 kg (od -15 do +15).
    // Iterujemy od 0 do 30, gdzie 'i' to przesunięcie od wartości min.
    const int totalSteps = 30;

    for (int i = 0; i <= totalSteps; i++) {
      // Obliczamy pozycję X.
      // i / 30 daje nam procentową pozycję na szerokości (0.0 na początku, 0.5 środek, 1.0 koniec)
      final double normalized = i / totalSteps;
      final double x = normalized * width;

      // Sprawdzamy czy to "główny" punkt (podzielny przez 5)
      // i = 0  -> -15kg (Start) -> Duża
      // i = 5  -> -10kg         -> Duża
      // ...
      // i = 15 ->   0kg (Środek)-> Duża (Idealnie na środku)
      // ...
      // i = 30 -> +15kg (Koniec)-> Duża
      final bool isMainTick = i % 5 == 0;

      if (isMainTick) {
        // DUŻA KRESKA
        const double tickHeight = 14.0;
        canvas.drawLine(
          Offset(x, size.height / 2 - tickHeight / 2),
          Offset(x, size.height / 2 + tickHeight / 2),
          mainTickPaint,
        );
      } else {
        // MAŁA KRESKA
        const double tickHeight = 7.0;
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
