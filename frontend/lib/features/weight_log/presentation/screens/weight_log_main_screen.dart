import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/dashboard/presentation/screens/weight_history_chart.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/presentation/widgets/weight_calendar_card.dart';
import 'package:frontend/features/weight_log/presentation/widgets/current_weight_card.dart';
import 'package:frontend/features/weight_log/presentation/widgets/time_since_latest_measurement_text.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

class WeightLogMainScreen extends StatefulWidget {
  const WeightLogMainScreen({super.key});

  @override
  State<WeightLogMainScreen> createState() => _WeightLogMainScreenState();
}

class _WeightLogMainScreenState extends State<WeightLogMainScreen> {
  late WeightLogService _weightLogService;

  bool _isLoading = false;
  List<WeightEntryModel> _weightEntries = [];
  WeightEntryModel? _latestEntry;

  @override
  void initState() {
    super.initState();
    _weightLogService = Provider.of<WeightLogService>(context, listen: false);
    _loadWeightEntries();
  }

  Future<void> _removeEntry(WeightEntryModel entry) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this entry?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await _weightLogService.deleteWeightEntry(entry);
      }
      await _loadWeightEntries();
    } catch (e) {
      AppLogger.error('WeightLogMainScreen._removeEntry error: $e');
    }
  }

  Future<void> _loadWeightEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<WeightEntryModel> entries = await _weightLogService.getAllWeightEntries();
      WeightEntryModel? latestEntry = await _weightLogService.getLatestWeightEntry();
      setState(() {
        _weightEntries = entries;
        _latestEntry = latestEntry;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppLogger.error('WeightLogMainScreen._loadWeightEntries error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weigh-In Log')),
      body: Column(
        children: [
          Expanded(
            child: WeightCalendar(
              weightEntries: _weightEntries,
              isLoading: _isLoading,
              removeEntry: _removeEntry,
            ),
          ),
          SizedBox(height: 250, child: WeightHistoryChart()),
          CurrentWeightCard(latestEntry: _latestEntry, handleAddWeightEntry: _handleAddWeightEntry),
        ],
      ),
    );
  }

  Future<void> _handleAddWeightEntry() async {
    await _weightLogService.addWeightEntry(
      WeightEntryModel.create(weight: 74.3, date: DateTime.utc(2025, 12, 10)),
    );
    await _loadWeightEntries();
  }
}
