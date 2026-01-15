import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/goal/data/goal_model.dart';

class PastGoalCard extends StatelessWidget {
  final GoalModel goal;

  const PastGoalCard({super.key, required this.goal});

  String _formatDate(DateTime date) {
    // Format daty np. 12 Jan 2024
    return DateFormat('MMM d, yyyy').format(date);
  }

  bool _isGoalAchieved() {
    // Sprawdzamy, czy cel został osiągnięty ("On Track" na koniec celu)
    // Jeśli endWeight jest null, zakładamy, że cel nie został poprawnie sfinalizowany.
    if (goal.endWeight == null) return false;

    if (goal.isWeightLoss) {
      // Dla odchudzania: końcowa waga musi być mniejsza lub równa celowi
      return goal.endWeight! <= goal.targetWeight;
    } else {
      // Dla przybierania na wadze: końcowa waga musi być większa lub równa celowi
      return goal.endWeight! >= goal.targetWeight;
    }
  }

  bool _wasGoalOnTrackAtEnd() {
    if (goal.endWeight == null) return false;

    final double progressCompletion =
        (goal.endWeight! - goal.startWeight) / (goal.targetWeight - goal.startWeight);
    final double timeCompletion = goal.endDate != null
        ? (goal.endDate!.difference(goal.startDate).inDays) /
              (goal.targetDate.difference(goal.startDate).inDays)
        : 0.0;

    return progressCompletion >= timeCompletion;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = _isGoalAchieved();
    final bool wasOnTrack = _wasGoalOnTrackAtEnd();
    final double finalWeight = goal.endWeight ?? goal.latestWeight ?? goal.startWeight;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSuccess
              ? Colors.green.withOpacity(0.3)
              : wasOnTrack
              ? Colors.lightBlue.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Rząd 1: Daty z niebieską ikonką kalendarza ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_today_outlined, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Goal Duration",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _formatDate(goal.startDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
                        ),
                        Text(
                          goal.endDate != null ? _formatDate(goal.endDate!) : "Ended",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),

            // --- Rząd 2: Waga i Wynik (Zielony/Czerwony) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sekcja Wagi
                Row(
                  children: [
                    // Start Weight
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Start", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        Text(
                          "${goal.startWeight.toStringAsFixed(1)} kg",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    // Strzałka
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.trending_flat, color: Colors.grey.shade400),
                    ),

                    // End Weight
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("End", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        Text(
                          "${finalWeight.toStringAsFixed(1)} kg",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),

                // Sekcja Statusu (Ikona Sukcesu/Porażki)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? Colors.green.shade50
                        : wasOnTrack
                        ? Colors.lightBlue.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSuccess ? Icons.check_circle : Icons.cancel,
                        color: isSuccess
                            ? Colors.green
                            : wasOnTrack
                            ? Colors.lightBlue
                            : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSuccess
                            ? "Done"
                            : wasOnTrack
                            ? "On Track"
                            : "Missed",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSuccess
                              ? Colors.green.shade700
                              : wasOnTrack
                              ? Colors.lightBlue.shade700
                              : Colors.red.shade700,
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

// Extension to safely get latest weight if endWeight is null logic helper
extension GoalModelExt on GoalModel {
  // Zakładam, że w modelu może nie być latestEntry, więc to tylko pomocnicze,
  // jeśli nie masz tego pola w modelu, usuń tę linijkę w `final double finalWeight = ...`
  // i użyj po prostu endWeight ?? startWeight.
  double? get latestWeight => null;
}
