import 'package:flutter/material.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

class AddWeightEntryBottomSheet extends StatefulWidget {
  const AddWeightEntryBottomSheet({super.key});

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
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final double? weight = double.tryParse(_weightController.text.replaceAll(',', '.'));

      if (weight != null) {
        if (context.read<WeightLogService>().entryExistsWithDate(_selectedDate)) {
          final oldEntry = await context.read<WeightLogService>().getEntryByDate(_selectedDate);
          oldEntry!.changeDate(_selectedDate);
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              onDateChanged: (newDate) {
                setState(() {
                  _selectedDate = newDate;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
