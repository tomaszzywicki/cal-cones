import 'package:flutter/material.dart';
import 'package:frontend/features/weight_log/presentation/widgets/weight_entry_list.dart';

class WeightEntryContainer extends StatelessWidget {
  const WeightEntryContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // WeightEntryCalendar(),
      WeightEntryList(),
    ];
    return Card(child: PageView(children: pages));
  }
}
