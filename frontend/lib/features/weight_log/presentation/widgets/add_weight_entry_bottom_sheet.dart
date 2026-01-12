import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

class AddWeightEntryBottomSheet extends StatefulWidget {
  final DateTime? initialDate;
  const AddWeightEntryBottomSheet({super.key, this.initialDate});

  @override
  State<AddWeightEntryBottomSheet> createState() => _AddWeightEntryBottomSheetState();
}

class _AddWeightEntryBottomSheetState extends State<AddWeightEntryBottomSheet> {
  late DateTime _selectedDate;
  final TextEditingController _weightController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final double? rawWeight = double.tryParse(_weightController.text.replaceAll(',', '.'));
      final double? weight = rawWeight != null ? (rawWeight * 10).roundToDouble() / 10 : null;

      if (weight != null) {
        if (context.read<WeightLogService>().entryExistsWithDate(_selectedDate)) {
          final oldEntry = await context.read<WeightLogService>().getEntryByDate(_selectedDate);
          if (mounted) {
            await context.read<WeightLogService>().changeWeightForEntry(oldEntry, weight);
            Navigator.of(context).pop();
          }
          return;
        }
        final newEntry = WeightEntryModel.create(weight: weight, date: _selectedDate);
        await context.read<WeightLogService>().addWeightEntry(newEntry);
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text("Add Weight Entry", style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(
            height: 300,
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              onDateChanged: (newDate) {
                setState(() {
                  _selectedDate = newDate;
                  AppLogger.debug("Selected date changed to: $_selectedDate");
                });
              },
            ),
          ),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your weight';
                }
                final weight = double.tryParse(value.replaceAll(',', '.'));
                if (weight == null || weight <= 0) {
                  return 'Please enter a valid weight';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _handleSave, child: const Text('Save entry')),
        ],
      ),
    );
  }
}
