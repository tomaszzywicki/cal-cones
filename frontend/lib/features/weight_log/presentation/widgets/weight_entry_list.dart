// import 'package:flutter/material.dart';
// import 'package:frontend/core/logger/app_logger.dart';
// import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
// import 'package:frontend/features/weight_log/presentation/widgets/edit_weight_entry_bottom_sheet.dart';
// import 'package:frontend/features/weight_log/services/weight_log_service.dart';
// import 'package:provider/provider.dart';

// class WeightEntryList extends StatelessWidget {
//   const WeightEntryList({super.key});

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

//   Future<void> handleEditWeightEntry(BuildContext context, WeightEntryModel entry) async {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
//       builder: (context) => EditWeightEntryBottomSheet(entry: entry),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final weightLogService = context.watch<WeightLogService>();
//     final weightEntries = weightLogService.entries;

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
//                 onTap: () async {
//                   await handleEditWeightEntry(context, entry);
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
import 'package:frontend/features/weight_log/presentation/widgets/edit_weight_entry_bottom_sheet.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

class WeightEntryList extends StatelessWidget {
  const WeightEntryList({super.key});

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
      AppLogger.error('WeightEntryList._deleteEntry error: $e');
    }
  }

  Future<void> handleEditWeightEntry(BuildContext context, WeightEntryModel entry) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) => EditWeightEntryBottomSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final weightEntries = weightLogService.entries;
    // Kolor z Twojego theme.dart
    final primaryColor = const Color(0xFF0F465D);

    if (weightEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monitor_weight_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text("Brak pomiarów", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: weightEntries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = weightEntries[index];
          final dateStr = entry.date.toLocal().toString().split(' ')[0];
          final timeStr = entry.date
              .toLocal()
              .toIso8601String()
              .split('T')[1]
              .split('.')[0]
              .substring(0, 5); // HH:MM

          return Dismissible(
            key: ValueKey(entry.id ?? entry.date.toString()),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              _deleteEntry(context, entry);
              return false; // Usuwanie obsługujemy w _deleteEntry
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            child: InkWell(
              onTap: () => handleEditWeightEntry(context, entry),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.scale, color: primaryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.weight} kg',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0C1C24),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$dateStr • $timeStr',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_outlined, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
