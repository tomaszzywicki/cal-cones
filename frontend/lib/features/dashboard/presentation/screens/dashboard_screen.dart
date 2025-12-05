import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/features/dashboard/presentation/screens/b_m_icard.dart';
import 'package:frontend/features/dashboard/presentation/screens/current_goal_card.dart';
import 'package:frontend/features/dashboard/presentation/screens/macro_intake_chart.dart';
import 'package:frontend/features/dashboard/presentation/screens/weigh_in_calendar_card.dart';
import 'package:frontend/features/dashboard/presentation/screens/weight_history_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.9,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [CurrentGoalCard(), WeighInCalendarCard()],
            ),
            AspectRatio(aspectRatio: 4.5, child: BMIcard()),
            AspectRatio(aspectRatio: 16 / 11, child: WeightHistoryChart()),
            AspectRatio(aspectRatio: 16 / 11, child: MacroIntakeChart()),
          ],
        ),
      ),
    );
  }
}
