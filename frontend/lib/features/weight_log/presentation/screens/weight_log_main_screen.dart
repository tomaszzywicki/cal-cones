import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
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

  @override
  void initState() {
    super.initState();
    _weightLogService = Provider.of<WeightLogService>(context, listen: false);
    _loadWeightEntries();
  }

  Future<void> _loadWeightEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<WeightEntryModel> entries = await _weightLogService.getAllWeightEntries();
      setState(() {
        _weightEntries = entries;
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
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await _handleAddWeightEntry();
              },
              child: Text("Add New Weigh-In"),
            ),
          ),
          Text("There are ${_weightEntries.length} entries."),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _weightEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _weightEntries[index];
                      return ListTile(
                        title: Text('${entry.weight} kg'),
                        subtitle: Text(
                          '${entry.date.toLocal()}'.split(' ')[0] +
                              ' ${entry.date.toLocal().toIso8601String().split('T')[1].split('.')[0]}',
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _handleAddWeightEntry() async {
    await _weightLogService.addWeightEntry(
      WeightEntryModel.create(weight: 72.3, date: DateTime.now().toUtc()),
    );
    await _loadWeightEntries();
  }
}
