import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

class EditWeightEntryBottomSheet extends StatefulWidget {
  final WeightEntryModel? entry;

  const EditWeightEntryBottomSheet({super.key, this.entry});

  @override
  State<EditWeightEntryBottomSheet> createState() => _EditWeightEntryBottomSheetState();
}

class _EditWeightEntryBottomSheetState extends State<EditWeightEntryBottomSheet> {
  final TextEditingController _weightController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        await context.read<WeightLogService>().changeWeightForEntry(widget.entry!, weight);
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text("Modify Weight Entry", style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(
            height: 300,
            child: Center(
              child: Text(
                '${widget.entry!.date.toLocal().toString().split(' ')[0]} (${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][widget.entry!.date.weekday - 1]})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
