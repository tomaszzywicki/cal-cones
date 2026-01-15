import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/goal/services/goal_service.dart';
import 'package:frontend/features/goal/presentation/widgets/active_goal_card.dart';
import 'package:frontend/features/goal/presentation/widgets/past_goal_card.dart';
// import 'package:frontend/features/user/presentation/screens/onboarding_screens/goal_setup.dart'; // Odkomentuj, gdy będziesz miał ten ekran

class GoalListScreen extends StatefulWidget {
  const GoalListScreen({super.key});

  @override
  State<GoalListScreen> createState() => _GoalListScreenState();
}

class _GoalListScreenState extends State<GoalListScreen> {
  late Future<List<GoalModel>> _goalsFuture;

  @override
  void initState() {
    super.initState();
    _refreshGoals();
  }

  void _refreshGoals() {
    setState(() {
      _goalsFuture = context.read<GoalService>().getGoalHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Nawigacja do ekranu edycji lub dodawania celu
          // Navigator.push(context, MaterialPageRoute(builder: (_) => GoalSetupScreen()));
        },
        label: const Text("Edit Goal"),
        icon: const Icon(Icons.edit),
        backgroundColor: Colors.black87,
      ),
      body: FutureBuilder<List<GoalModel>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Jeśli nie ma danych w ogóle (null), traktujemy to jako pustą listę
          final allGoals = snapshot.data ?? [];

          // 1. Znajdź aktywny cel
          GoalModel? activeGoal;
          try {
            activeGoal = allGoals.firstWhere((g) => g.isCurrent);
          } catch (e) {
            activeGoal = null;
          }

          // 2. Znajdź i posortuj stare cele (od najnowszych)
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
                // Opcjonalnie: Stan, gdy nie ma nawet aktywnego celu
                const Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text("No active goal set.")),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // --- SEKCJA HISTORII ---
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  "Goal History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),

              if (pastGoals.isEmpty)
                // --- PUSTY STAN HISTORII (EMPTY STATE) ---
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
                      Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.shade300),
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
                )
              else
                // --- LISTA STARYCH CELÓW ---
                ...pastGoals.map((goal) => PastGoalCard(goal: goal)),

              // Padding pod FAB
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
