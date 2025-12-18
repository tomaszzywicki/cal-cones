import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/dashboard/presentation/screens/weight_history_chart.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/presentation/widgets/weight_calendar_card.dart';
import 'package:frontend/features/weight_log/presentation/widgets/current_weight_card.dart';
import 'package:frontend/features/weight_log/presentation/widgets/time_since_latest_measurement_text.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

class WeightLogMainScreen extends StatelessWidget {
  const WeightLogMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weigh-In Log'), centerTitle: true, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          reverse: true,
          physics: BouncingScrollPhysics(),
          slivers: [
            // SliverToBoxAdapter(child: CurrentWeightCard()),
            SliverAppBar(
              expandedHeight: 180,
              toolbarHeight: 180,
              flexibleSpace: CurrentWeightCard(),
              backgroundColor: Colors.transparent,
              pinned: true,
            ),
            SliverToBoxAdapter(child: SizedBox(height: 250, child: WeightHistoryChart())),

            SliverToBoxAdapter(child: WeightCalendar()),
          ],
        ),
      ),
    );
  }
}
