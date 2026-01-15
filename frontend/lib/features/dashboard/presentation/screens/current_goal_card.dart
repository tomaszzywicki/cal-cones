import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/goal/services/goal_service.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:frontend/features/goal/data/goal_model.dart';

class CurrentGoalCard extends StatelessWidget {
  const CurrentGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get Weight Synchronously from Provider
    final weightLogService = context.watch<WeightLogService>();
    final double? currentWeight = weightLogService.latestEntry?.weight;

    // 2. Get Goal Asynchronously via FutureBuilder
    return FutureBuilder<GoalModel?>(
      future: context.read<GoalService>().getActiveGoal(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            color: Colors.white,
            child: SizedBox(
              height: 140, // Reduced height for loading state
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }

        final activeGoal = snapshot.data;

        if (activeGoal == null) {
          return const Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Center(
                child: Text("No active goal", style: TextStyle(color: Colors.grey)),
              ),
            ),
          );
        }

        // 3. Render Content
        return _buildGoalContent(activeGoal, currentWeight ?? activeGoal.startWeight);
      },
    );
  }

  Widget _buildGoalContent(GoalModel goal, double currentWeight) {
    final now = DateTime.now();

    // --- 1. TIME CALCULATIONS ---
    final totalDays = goal.targetDate.difference(goal.startDate).inDays;
    final daysElapsed = now.difference(goal.startDate).inDays;
    final daysRemaining = goal.targetDate.difference(now).inDays;

    double timeProgress = 0.0;
    if (totalDays > 0) {
      timeProgress = (daysElapsed / totalDays).clamp(0.0, 1.0);
    }

    // --- 2. WEIGHT CALCULATIONS ---
    final double start = goal.startWeight;
    final double target = goal.targetWeight;

    double weightProgress = 0.0;
    final totalDist = (start - target).abs();
    final coveredDist = (start - currentWeight).abs();

    // Check direction
    bool isMovingRightWay = goal.isWeightLoss ? currentWeight <= start : currentWeight >= start;

    if (totalDist > 0 && isMovingRightWay) {
      weightProgress = (coveredDist / totalDist).clamp(0.0, 1.0);
    }

    // Statuses
    bool isGoalReached = weightProgress >= 1.0;

    // Logic: Green if weight progress >= time progress, else Red
    Color weightBarColor = weightProgress >= timeProgress ? Colors.green : Colors.red;

    // Weight change text
    final change = goal.totalWeightChange;
    final changeStr = change > 0 ? "+${change.toStringAsFixed(1)}" : change.toStringAsFixed(1);

    return Card(
      elevation: 1, // Reduced elevation for a cleaner look
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0), // Compact padding
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content height
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER: Start -> Target ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCompactWeightInfo("Start", start),
                Column(
                  children: [
                    Text(
                      "$changeStr kg",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 10),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                  ],
                ),
                _buildCompactWeightInfo("Goal", target),
              ],
            ),

            const SizedBox(height: 12), // Reduced spacing
            // --- TIME PROGRESS ---
            _buildCompactProgressRow(
              label: "Time",
              statusText: daysRemaining > 0 ? "$daysRemaining days left" : "Time's up",
              progress: timeProgress,
              barColor: Colors.blue,
              textColor: Colors.blue,
            ),

            const SizedBox(height: 8), // Reduced spacing
            // --- WEIGHT PROGRESS ---
            _buildCompactProgressRow(
              label: "Progress",
              statusText: isGoalReached
                  ? "DONE!"
                  : (!isMovingRightWay ? "No progress" : "${(weightProgress * 100).toInt()}%"),
              progress: weightProgress,
              barColor: isGoalReached ? Colors.green : weightBarColor,
              textColor: isGoalReached ? Colors.green : (!isMovingRightWay ? Colors.red : weightBarColor),
            ),

            const SizedBox(height: 8), // Reduced spacing
            // --- FOOTER: Dates (Very small) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd.MM').format(goal.startDate),
                  style: TextStyle(color: Colors.grey[400], fontSize: 9),
                ),
                Text(
                  "Ends: ${DateFormat('dd.MM.yy').format(goal.targetDate)}",
                  style: TextStyle(color: Colors.grey[400], fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactWeightInfo(String label, double weight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          "${weight.toStringAsFixed(1)}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildCompactProgressRow({
    required String label,
    required String statusText,
    required double progress,
    required Color barColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and Status on the same line to save space
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(
              statusText,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6, // Thinner bar
            backgroundColor: Colors.grey.shade100,
            color: barColor,
          ),
        ),
      ],
    );
  }
}
