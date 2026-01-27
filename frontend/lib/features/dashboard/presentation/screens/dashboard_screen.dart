import 'package:flutter/material.dart';
import 'package:frontend/core/mixins/day_refresh_mixin.dart';
import 'package:frontend/features/dashboard/presentation/screens/bmi_card.dart';
import 'package:frontend/features/dashboard/presentation/screens/bmi_screen.dart';
import 'package:frontend/features/dashboard/presentation/screens/current_goal_card.dart';
import 'package:frontend/features/dashboard/presentation/screens/macro_intake_chart.dart';
import 'package:frontend/features/dashboard/presentation/screens/weigh_in_calendar_card.dart';
import 'package:frontend/features/dashboard/presentation/screens/weight_history_chart.dart';
import 'package:frontend/features/goal/presentation/screens/goal_list_screen.dart';
import 'package:frontend/features/weight_log/presentation/screens/weight_log_main_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver, DayRefreshMixin {
  @override
  void onDayChanged() {
    setState(() {
      // Rebuilds the UI with the new date
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.9,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                GestureDetector(
                  // FIX: Czekamy na powrót z ekranu celów i odświeżamy Dashboard
                  onTap: () async {
                    await Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => GoalListScreen()));
                    setState(() {});
                  },
                  child: CurrentGoalCard(),
                ),
                GestureDetector(
                  // FIX: To samo dla ekranu wagi, aby kalendarz i wykresy odświeżyły się po dodaniu wpisu
                  onTap: () async {
                    await Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => WeightLogMainScreen()));
                    setState(() {});
                  },
                  child: WeighInCalendarCard(),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => BmiScreen()));
              },
              child: BMIcard(isExpanded: false),
            ),
            const SizedBox(height: 24),

            // Tytuł wykresu
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Weight History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // AspectRatio(aspectRatio: 16 / 16, child: WeightHistoryChart()),
            WeightHistoryChart(),
            const SizedBox(height: 16),
            // AspectRatio(aspectRatio: 16 / 16, child: MacroIntakeChart()),
            // Tytuł wykresu
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Macro Intake (Last 7 Days)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            MacroIntakeChart(),
          ],
        ),
      ),
    );
  }
}
