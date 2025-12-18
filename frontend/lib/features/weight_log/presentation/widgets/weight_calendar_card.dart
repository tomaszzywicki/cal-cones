import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

class WeightCalendar extends StatelessWidget {
  const WeightCalendar({super.key});

  Future<void> _deleteEntry(BuildContext context, WeightEntryModel entry) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this entry?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        if (!context.mounted) return;
        await context.read<WeightLogService>().deleteWeightEntry(entry);
      }
    } catch (e) {
      AppLogger.error('WeightCalendar._deleteEntry error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final weightEntries = weightLogService.entries;
    final isLoading = false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("There are ${weightEntries.length} entries."),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: weightEntries.length,
                    itemBuilder: (context, index) {
                      final entry = weightEntries[index];
                      return ListTile(
                        title: Text('${entry.weight} kg'),
                        subtitle: Text(
                          '${entry.date.toLocal().toString().split(' ')[0]} ${entry.date.toLocal().toIso8601String().split('T')[1].split('.')[0]}',
                        ),
                        onLongPress: () {
                          _deleteEntry(context, entry);
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
