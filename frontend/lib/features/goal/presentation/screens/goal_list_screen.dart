import 'package:flutter/material.dart';
import 'package:frontend/core/mixins/day_refresh_mixin.dart';
import 'package:frontend/features/goal/presentation/screens/goal_setup.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/goal/services/goal_service.dart';
import 'package:frontend/features/goal/presentation/widgets/active_goal_card.dart';
import 'package:frontend/features/goal/presentation/widgets/past_goal_card.dart';

class GoalListScreen extends StatefulWidget {
  const GoalListScreen({super.key});

  @override
  State<GoalListScreen> createState() => _GoalListScreenState();
}

class _GoalListScreenState extends State<GoalListScreen> with WidgetsBindingObserver, DayRefreshMixin {
  late Future<List<GoalModel>> _goalsFuture;

  @override
  void initState() {
    super.initState();
    _refreshGoals();
  }

  @override
  void onDayChanged() {
    _refreshGoals();
  }

  void _refreshGoals() {
    setState(() {
      _goalsFuture = context.read<GoalService>().getGoalHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.read<WeightLogService>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Goals'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<GoalModel>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allGoals = snapshot.data ?? [];

          // 1. Znajdź aktywny cel
          GoalModel? activeGoal;
          try {
            activeGoal = allGoals.firstWhere((g) => g.isCurrent);
          } catch (e) {
            activeGoal = null;
          }

          // 2. Znajdź i posortuj stare cele
          // Sortujemy malejąco po dacie startu (najnowsze na górze listy historii)
          final pastGoals = allGoals.where((g) => !g.isCurrent).toList()
            ..sort((a, b) => b.startDate.compareTo(a.startDate));

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- SEKCJA AKTYWNEGO CELU ---
              if (activeGoal != null) ...[
                ActiveGoalCard(goal: activeGoal),
                const SizedBox(height: 24),
              ] else ...[
                const Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text("No active goal set.")),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // --- PRZYCISK ---
              Container(
                margin: const EdgeInsets.only(bottom: 32.0),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final double currentWeight =
                        weightLogService.latestEntry?.weight ?? activeGoal?.startWeight ?? 70.0;
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoalSetupScreen(
                          currentWeight: currentWeight,
                          isReplacingExistingGoal: activeGoal != null,
                        ),
                      ),
                    );
                    if (result == true) {
                      _refreshGoals();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black45,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(
                    activeGoal != null ? Icons.edit_outlined : Icons.add_circle_outline,
                    size: 24,
                    color: Colors.white,
                  ),
                  label: Text(
                    activeGoal != null ? "Edit Current Goal" : "Set New Goal",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ),

              // --- SEKCJA HISTORII ---
              if (pastGoals.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    "Goal History",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                ...pastGoals.map((goal) => PastGoalCard(goal: goal)),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        "No past goals recorded yet.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
