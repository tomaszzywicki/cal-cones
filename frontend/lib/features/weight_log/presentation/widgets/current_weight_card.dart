import 'package:flutter/material.dart';
import 'package:frontend/features/weight_log/presentation/widgets/add_weight_entry_bottom_sheet.dart';
import 'package:frontend/features/weight_log/presentation/widgets/time_since_latest_measurement_text.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

class CurrentWeightCard extends StatelessWidget {
  const CurrentWeightCard({super.key});

  Future<void> handleAddWeightEntry(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) => AddWeightEntryBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final latestEntry = weightLogService.latestEntry;

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
                  "${latestEntry?.weight ?? 'N/A'} kg",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xff44638b),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await handleAddWeightEntry(context);
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
            TimeSinceLatestMeasurementText(latestEntry),
          ],
        ),
      ),
    );
  }
}
