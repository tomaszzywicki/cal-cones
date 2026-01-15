import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/goal/services/goal_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
// Zakładam, że ten widget jest dostępny pod tą ścieżką
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class GoalSetupScreen extends StatefulWidget {
  final double currentWeight;
  final bool isReplacingExistingGoal;

  const GoalSetupScreen({super.key, required this.currentWeight, this.isReplacingExistingGoal = false});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  late double _targetWeight;
  late double _tempo; // kg/week
  DateTime? _estimatedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Domyślnie proponujemy cel -5kg (lub +5kg jeśli ktoś jest bardzo lekki),
    // ale w granicach rozsądku.
    _targetWeight = (widget.currentWeight - 5.0).clamp(40.0, 200.0);
    _tempo = 0.5;
    _calculateDate();
  }

  void _calculateDate() {
    final diff = (widget.currentWeight - _targetWeight).abs();

    // Zabezpieczenie: jeśli cel == waga obecna lub tempo zerowe
    if (diff < 0.1 || _tempo <= 0) {
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
        id: 0, // Backend nada ID
        userId: userId,
        startDate: DateTime.now(),
        targetDate: _estimatedDate!,
        startWeight: widget.currentWeight,
        targetWeight: _targetWeight,
        tempo: _tempo,
        isCurrent: true,
      );

      // Używamy metody, która zamyka stary cel i otwiera nowy
      await context.read<GoalService>().setNewGoal(newGoal, closedGoalFinalWeight: widget.currentWeight);

      if (mounted) {
        Navigator.pop(context, true); // Wracamy z sukcesem
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Określamy czy to odchudzanie czy przybieranie na wadze
    final bool isWeightLoss = _targetWeight < widget.currentWeight;
    final double weightDiff = (widget.currentWeight - _targetWeight).abs();

    return Scaffold(
      backgroundColor: Colors.white, // Czyste białe tło jak w onboardingu
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Goal Setup",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                children: [
                  // --- OSTRZEŻENIE O ZAMKNIĘCIU STAREGO CELU ---
                  if (widget.isReplacingExistingGoal) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade800, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Attention",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Setting a new goal will finish your current active goal today. This action cannot be undone.",
                                  style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // --- NAGŁÓWEK ---
                  const Text(
                    "What is your target weight?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Current: ${widget.currentWeight} kg",
                    style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // --- WYBÓR WAGI DOCELOWEJ ---
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _targetWeight.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            letterSpacing: -2.0,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "kg",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Etykieta różnicy (+5kg / -5kg)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isWeightLoss ? Colors.green.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${isWeightLoss ? '-' : '+'}${weightDiff.toStringAsFixed(1)} kg",
                        style: TextStyle(
                          color: isWeightLoss ? Colors.green.shade700 : Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Suwak Wagi
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.black,
                      inactiveTrackColor: Colors.grey.shade200,
                      thumbColor: Colors.black,
                      overlayColor: Colors.black12,
                      trackHeight: 8.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    ),
                    child: Slider(
                      value: _targetWeight,
                      min: 40.0,
                      max: 150.0,
                      onChanged: (val) {
                        setState(() {
                          _targetWeight = val;
                          _calculateDate();
                        });
                        HapticFeedback.selectionClick();
                      },
                    ),
                  ),

                  const SizedBox(height: 48),

                  // --- WYBÓR TEMPA ---
                  const Text(
                    "Choose your pace",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Weekly change",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "${_tempo.toStringAsFixed(1)} kg",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.blueGrey.shade800,
                            inactiveTrackColor: Colors.blueGrey.shade100,
                            thumbColor: Colors.blueGrey.shade900,
                            trackHeight: 6.0,
                          ),
                          child: Slider(
                            value: _tempo,
                            min: 0.1,
                            max: 1.5,
                            divisions: 14,
                            onChanged: (val) {
                              setState(() {
                                _tempo = val;
                                _calculateDate();
                              });
                              HapticFeedback.selectionClick();
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Slow & Steady",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              "Aggressive",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- ESTYMACJA DATY ---
                  if (_estimatedDate != null)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Estimated finish date",
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMMM d, yyyy').format(_estimatedDate!),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // --- PRZYCISK (Bottom) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: SizedBox(
                width: double.infinity,
                // Próba użycia OnboardingButton z pakietu użytkownika
                // Jeśli OnboardingButton ma inne parametry, wstawimy tu zwykły ElevatedButton
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : OnboardingButton(text: "Confirm New Goal", onPressed: _saveGoal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
