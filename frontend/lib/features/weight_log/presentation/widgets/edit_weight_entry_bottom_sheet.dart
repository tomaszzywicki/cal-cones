import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditWeightEntryBottomSheet extends StatefulWidget {
  final WeightEntryModel entry;

  const EditWeightEntryBottomSheet({super.key, required this.entry});

  @override
  State<EditWeightEntryBottomSheet> createState() => _EditWeightEntryBottomSheetState();
}

class _EditWeightEntryBottomSheetState extends State<EditWeightEntryBottomSheet> {
  late DateTime _selectedDate;
  late TextEditingController _weightController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFF0F465D);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.entry.date;
    _weightController = TextEditingController(text: widget.entry.weight.toString());
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final double? rawWeight = double.tryParse(_weightController.text.replaceAll(',', '.'));
      final double? weight = rawWeight != null ? (rawWeight * 10).roundToDouble() / 10 : null;

      if (weight != null) {
        // Sprawdź czy użytkownik zmienił datę na taką, gdzie już jest inny wpis (i to nie ten sam)
        final normalizedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        final weightLogService = context.read<WeightLogService>();

        // Logika aktualizacji
        WeightEntryModel updatedEntry = widget.entry;

        // Jeśli zmieniła się waga
        if (weight != widget.entry.weight) {
          updatedEntry.weight = weight;
        }

        // Jeśli zmieniła się data (tutaj uproszczone, normalnie service powinien to obsłużyć)
        // W obecnym serwisie changeWeightForEntry aktualizuje tylko wagę.
        // Jeśli zmieniamy datę, zazwyczaj lepiej usunąć stary i dodać nowy lub zaktualizować oba pola.
        // Zakładamy tutaj, że UI pozwala edytować datę, więc musimy to obsłużyć.

        // Szybki fix: Jeśli data się zmieniła, aktualizujemy obiekt.
        // Uwaga: Twoja implementacja WeightEntryModel ma metody changeDate i changeWeight
        // ale musimy to zapisać w bazie/serwisie.

        if (!DateUtils.isSameDay(widget.entry.date, _selectedDate)) {
          // Jeśli data się zmieniła, sprawdźmy kolizję
          if (weightLogService.entryExistsWithDate(normalizedDate)) {
            // Kolizja - wpis już jest. Możemy zapytać czy nadpisać.
            // Tutaj: pokaż snackbar i nie rób nic
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Wpis z tą datą już istnieje!')));
            return;
          }
          // Aktualizacja w bazie (zakładamy, że delete + add lub update obsłuży to)
          // Tutaj użyjemy delete + add jako bezpiecznej metody, chyba że service ma updateEntry
          await weightLogService.deleteWeightEntry(widget.entry);
          final newEntry = WeightEntryModel.create(weight: weight, date: _selectedDate);
          await weightLogService.addWeightEntry(newEntry);
        } else {
          // Tylko waga się zmieniła
          await weightLogService.changeWeightForEntry(widget.entry, weight);
        }

        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleDelete() async {
    // Potwierdzenie usunięcia
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Usuń pomiar"),
        content: const Text("Czy na pewno chcesz usunąć ten wpis?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Anuluj")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Usuń", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<WeightLogService>().deleteWeightEntry(widget.entry);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d MMMM yyyy').format(_selectedDate);

    return Container(
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Uchwyt
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pusty widget dla symetrii lub przycisk anuluj
                  const SizedBox(width: 48),
                  Text(
                    "Edytuj pomiar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                  ),
                  // Przycisk kosza
                  IconButton(
                    onPressed: _handleDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: "Usuń wpis",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // INPUT WAGI
              Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    IntrinsicWidth(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                          height: 1.0,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          hintStyle: TextStyle(color: Colors.grey.shade300),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '';
                          final weight = double.tryParse(value.replaceAll(',', '.'));
                          if (weight == null || weight <= 0) return '';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "kg",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Wybór daty
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: _primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            formattedDate,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _primaryColor),
                          ),
                          const Spacer(),
                          Text(
                            "Zmień",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    SizedBox(
                      height: 250,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(colorScheme: ColorScheme.light(primary: _primaryColor)),
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
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Przycisk Aktualizuj
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Zaktualizuj",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
