import 'package:flutter/material.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/presentation/widgets/time_since_latest_measurement_text.dart';

class CurrentWeightCard extends StatefulWidget {
  final WeightEntryModel? latestEntry;
  final Future<void> Function() handleAddWeightEntry;

  const CurrentWeightCard({super.key, required this.latestEntry, required this.handleAddWeightEntry});

  @override
  State<CurrentWeightCard> createState() => _CurrentWeightCardState();
}

class _CurrentWeightCardState extends State<CurrentWeightCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your current weight", style: Theme.of(context).textTheme.headlineMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.latestEntry?.weight ?? 'N/A'} kg",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xff44638b),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await widget.handleAddWeightEntry();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(fontSize: 60, fontWeight: FontWeight.w900),
                    fixedSize: const Size(80, 80),
                    backgroundColor: const Color(0xff44638b),
                  ),
                  child: Text("+"),
                ),
              ],
            ),
            TimeSinceLatestMeasurementText(widget.latestEntry),
          ],
        ),
      ),
    );
  }
}
