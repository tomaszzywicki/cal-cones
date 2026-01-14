import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/goal/services/goal_service.dart';
import 'package:provider/provider.dart';

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
    final goalService = context.read<GoalService>();
    _goalsFuture = goalService.getGoalHistory();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historia Celów'), centerTitle: true),
      body: FutureBuilder<List<GoalModel>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak zapisanych celów.'));
          }

          final goals = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _buildGoalCard(goal);
            },
          );
        },
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final theme = Theme.of(context);
    final isCurrent = goal.isCurrent;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCurrent ? 'Aktywny Cel' : 'Zakończony',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isCurrent ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (goal.endDate != null)
                  Text('Koniec: ${_formatDate(goal.endDate!)}', style: theme.textTheme.bodySmall),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Okres:', '${_formatDate(goal.startDate)} - ${_formatDate(goal.targetDate)}'),
            const SizedBox(height: 4),
            _buildInfoRow('Waga początkowa:', '${goal.startWeight} kg'),
            const SizedBox(height: 4),
            _buildInfoRow('Cel wagi:', '${goal.targetWeight} kg'),
            const SizedBox(height: 4),
            _buildInfoRow('Tempo:', '${goal.tempo} kg/tydzień'),
            if (!isCurrent && goal.endWeight != null) ...[
              const SizedBox(height: 4),
              _buildInfoRow('Waga końcowa:', '${goal.endWeight} kg', isBold: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(
          value,
          style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.black87),
        ),
      ],
    );
  }
}
