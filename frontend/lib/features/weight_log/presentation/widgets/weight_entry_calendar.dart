// import 'package:flutter/material.dart';
// import 'package:frontend/core/logger/app_logger.dart';
// import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
// import 'package:frontend/features/weight_log/services/weight_log_service.dart';
// import 'package:provider/provider.dart';

// class WeightEntryCalendar extends StatelessWidget {
//   const WeightEntryCalendar({super.key});

//   Future<void> _deleteEntry(BuildContext context, WeightEntryModel entry) async {
//     try {
//       bool? confirmDelete = await showDialog<bool>(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Confirm Deletion'),
//             content: const Text('Are you sure you want to delete this entry?'),
//             actions: [
//               TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
//               TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
//             ],
//           );
//         },
//       );

//       if (confirmDelete == true) {
//         if (!context.mounted) return;
//         await context.read<WeightLogService>().deleteWeightEntry(entry);
//       }
//     } catch (e) {
//       AppLogger.error('WeightCalendar._deleteEntry error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final weightLogService = context.watch<WeightLogService>();
//     final weightEntries = weightLogService.entries;
//     final isLoading = false;

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: weightEntries.length,
//             itemBuilder: (context, index) {
//               final entry = weightEntries[index];
//               return ListTile(
//                 title: Text('${entry.weight} kg'),
//                 subtitle: Text(
//                   '${entry.date.toLocal().toString().split(' ')[0]} ${entry.date.toLocal().toIso8601String().split('T')[1].split('.')[0]}',
//                 ),
//                 onLongPress: () {
//                   _deleteEntry(context, entry);
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

class WeightEntryCalendar extends StatelessWidget {
  const WeightEntryCalendar({super.key});

  Future<void> _deleteEntry(BuildContext context, WeightEntryModel entry) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Usuń wpis'),
            content: const Text('Czy na pewno chcesz usunąć ten pomiar?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Anuluj')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Usuń', style: TextStyle(color: Colors.red)),
              ),
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

    // Sortowanie (opcjonalne, dla pewności)
    final sortedEntries = List<WeightEntryModel>.from(weightEntries)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 4),
            child: Text(
              "Wszystkie wpisy",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0C1C24)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedEntries.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final entry = sortedEntries[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  leading: const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF0F465D)),
                  title: Text('${entry.weight} kg', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${entry.date.toLocal().toString().split(' ')[0]} ${entry.date.toLocal().toIso8601String().split('T')[1].split('.')[0].substring(0, 5)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                    onPressed: () => _deleteEntry(context, entry),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
