import 'package:flutter/material.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';

class WeightCalendar extends StatefulWidget {
  const WeightCalendar({
    super.key,
    required this.weightEntries,
    required this.isLoading,
    required this.removeEntry,
  });

  final List<WeightEntryModel> weightEntries;
  final bool isLoading;
  final void Function(WeightEntryModel) removeEntry;

  @override
  State<WeightCalendar> createState() => _WeightCalendarState();
}

class _WeightCalendarState extends State<WeightCalendar> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("There are ${widget.weightEntries.length} entries."),
            widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: widget.weightEntries.length,
                      itemBuilder: (context, index) {
                        final entry = widget.weightEntries[index];
                        return ListTile(
                          title: Text('${entry.weight} kg'),
                          subtitle: Text(
                            '${entry.date.toLocal().toString().split(' ')[0]} ${entry.date.toLocal().toIso8601String().split('T')[1].split('.')[0]}',
                          ),
                          onLongPress: () {
                            widget.removeEntry(entry);
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
