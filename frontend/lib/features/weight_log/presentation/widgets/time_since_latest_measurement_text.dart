import 'package:flutter/material.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';

class TimeSinceLatestMeasurementText extends StatelessWidget {
  final WeightEntryModel? latestEntry;

  const TimeSinceLatestMeasurementText(this.latestEntry, {super.key});

  @override
  Widget build(BuildContext context) {
    if (latestEntry == null) {
      return Text(
        "Never measured",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }
    final days = latestEntry!.daysSinceToday().abs();
    if (days == 0) {
      return Row(
        children: [
          Text('measured '),
          Text(
            "today",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      );
    } else if (days == 1) {
      return Row(
        children: [
          Text('measured '),
          Text(
            "yesterday",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        ],
      );
    } else if (days <= 7) {
      return Row(
        children: [
          Text('measured '),
          Text(
            "$days days ago",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Text('measured '),
          Text(
            "$days days ago",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      );
    }
  }
}
