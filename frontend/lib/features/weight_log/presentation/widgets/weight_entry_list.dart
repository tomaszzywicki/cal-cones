import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/presentation/widgets/edit_weight_entry_bottom_sheet.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Upewnij się, że masz to zainicjalizowane w main.dart, jeśli używasz polskiego locale

class WeightEntryList extends StatelessWidget {
  const WeightEntryList({super.key});

  Future<void> _deleteEntry(BuildContext context, WeightEntryModel entry) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Usuń wpis'),
            content: const Text('Czy na pewno chcesz usunąć ten pomiar?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Anuluj')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Usuń', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        if (!context.mounted) return;
        await context.read<WeightLogService>().deleteWeightEntry(entry);
      }
    } catch (e) {
      AppLogger.error('WeightEntryList._deleteEntry error: $e');
    }
  }

  Future<void> handleEditWeightEntry(BuildContext context, WeightEntryModel entry) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) => EditWeightEntryBottomSheet(entry: entry),
    );
  }

  String _formatDay(DateTime date) {
    // Np. 12 Tue (Dzień i skrót dnia tygodnia)
    return DateFormat('d EEE', 'en_US').format(date);
    // Jeśli nie używasz pl_PL, zmień na 'en_US' lub usuń parametr locale
  }

  String _formatMonthYear(DateTime date) {
    // Np. Październik 2024
    return DateFormat('MMMM yyyy', 'en_US').format(date);
    // Jeśli nie używasz pl_PL, zmień na 'en_US' lub usuń parametr locale
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final weightEntries = weightLogService.entries;

    // Sortowanie malejąco po dacie (najnowsze na górze)
    weightEntries.sort((a, b) => b.date.compareTo(a.date));

    if (weightEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monitor_weight_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text("Brak pomiarów", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    // Generowanie widoku zgrupowanego
    final groupedWidgets = _buildGroupedList(context, weightEntries);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Scrollowanie obsługiwane przez rodzica
        itemCount: groupedWidgets.length,
        itemBuilder: (context, index) => groupedWidgets[index],
      ),
    );
  }

  List<Widget> _buildGroupedList(BuildContext context, List<WeightEntryModel> entries) {
    List<Widget> widgets = [];

    // Ustawiamy zakres dat od najnowszego wpisu do najstarszego
    // Normalizujemy do pierwszego dnia miesiąca, aby łatwiej iterować
    DateTime newestDate = entries.first.date;
    DateTime oldestDate = entries.last.date;

    DateTime currentMonthCursor = DateTime(newestDate.year, newestDate.month, 1);
    DateTime endMonthCursor = DateTime(oldestDate.year, oldestDate.month, 1);

    List<DateTime> emptyMonthsBuffer = [];

    // Pętla iterująca miesiącami w dół
    while (!currentMonthCursor.isBefore(endMonthCursor)) {
      // Pobierz wpisy dla obecnego miesiąca kursora
      final monthEntries = entries.where((e) {
        return e.date.year == currentMonthCursor.year && e.date.month == currentMonthCursor.month;
      }).toList();

      if (monthEntries.isNotEmpty) {
        // 1. Jeśli mieliśmy zgromadzone puste miesiące, dodaj informację o nich
        if (emptyMonthsBuffer.isNotEmpty) {
          widgets.add(_buildEmptyMonthsInfo(emptyMonthsBuffer));
          emptyMonthsBuffer.clear();
        }

        // 2. Dodaj kartę z pomiarami dla tego miesiąca
        widgets.add(_buildMonthCard(context, currentMonthCursor, monthEntries));
      } else {
        // Brak wpisów w tym miesiącu - dodaj do bufora
        emptyMonthsBuffer.add(currentMonthCursor);
      }

      // Cofnij się o jeden miesiąc
      currentMonthCursor = DateTime(currentMonthCursor.year, currentMonthCursor.month - 1, 1);
    }

    // (Opcjonalnie) Jeśli na samym końcu (poniżej najstarszego wpisu) byłyby puste miesiące,
    // logika pętli while (!isBefore(end)) zapobiega wejściu tutaj, bo endMonthCursor to miesiąc najstarszego wpisu.
    // Więc teoretycznie bufor tutaj powinien być pusty, chyba że zmienimy logikę zakresu.

    return widgets;
  }

  Widget _buildEmptyMonthsInfo(List<DateTime> emptyMonths) {
    // emptyMonths są w kolejności malejącej (np. Grudzień, Listopad...)
    // Chcemy wyświetlić zakres chronologicznie: Listopad - Grudzień
    final oldestEmpty = emptyMonths.last;
    final newestEmpty = emptyMonths.first;

    String text;
    if (emptyMonths.length == 1) {
      text = "${_formatMonthYear(newestEmpty)}:\tno entries";
      // text = "${_formatMonthYear(newestEmpty)}:";
    } else {
      text = "${_formatMonthYear(oldestEmpty)} - ${_formatMonthYear(newestEmpty)}:\tno entries";
      // text = "${_formatMonthYear(oldestEmpty)} - ${_formatMonthYear(newestEmpty)}:";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontStyle: FontStyle.italic),
            textAlign: TextAlign.left,
          ),
          // Text(
          //   "no entries",
          //   style: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontStyle: FontStyle.italic),
          // ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(BuildContext context, DateTime monthDate, List<WeightEntryModel> entries) {
    final primaryColor = const Color(0xFF0F465D);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nagłówek miesiąca
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              _formatMonthYear(monthDate).toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: primaryColor,
              ),
            ),
          ),

          // Lista wpisów wewnątrz karty
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildEntryRow(context, entry);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEntryRow(BuildContext context, WeightEntryModel entry) {
    return InkWell(
      onLongPress: () => _deleteEntry(context, entry),
      onTap: () => handleEditWeightEntry(context, entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Dzień miesiąca (np. 12 Pon)
            Container(
              width: 50,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('d').format(entry.date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C1C24),
                    ),
                  ),
                  Text(
                    DateFormat('EEE', 'en_US').format(entry.date).toUpperCase(), // Skrót dnia tyg.
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Waga
            Expanded(
              child: Row(
                children: [
                  Text(
                    '${entry.weight}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F465D),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      height: 1.5, // Wyrównanie do linii tekstu
                    ),
                  ),
                ],
              ),
            ),

            // Ikona edycji/akcji (subtelna)
            Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}
