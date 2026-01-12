import 'package:flutter/material.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/presentation/widgets/add_weight_entry_bottom_sheet.dart';
import 'package:frontend/features/weight_log/presentation/widgets/edit_weight_entry_bottom_sheet.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class WeightEntryCalendar extends StatelessWidget {
  const WeightEntryCalendar({super.key});

  /// Normalizuje datę do samej daty (bez czasu: 00:00:00)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _handleDayTap(BuildContext context, DateTime date, WeightEntryModel? entry) {
    if (entry != null) {
      // Edycja istniejącego wpisu
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (context) => EditWeightEntryBottomSheet(entry: entry),
      );
    } else {
      // Dodawanie nowego wpisu z wybraną datą
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (context) => AddWeightEntryBottomSheet(initialDate: date),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final weightEntries = weightLogService.entries;

    if (weightEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1. Przygotowanie danych - mapujemy DateTime -> WeightEntryModel
    final Map<DateTime, WeightEntryModel> entriesByDate = {};
    for (var entry in weightEntries) {
      final dateKey = _normalizeDate(entry.date.toLocal());
      if (!entriesByDate.containsKey(dateKey)) {
        entriesByDate[dateKey] = entry;
      }
    }

    // 2. Wyznaczenie zakresu miesięcy
    final sortedEntries = List.of(weightEntries)..sort((a, b) => a.date.compareTo(b.date));
    final oldestEntryDate = sortedEntries.first.date.toLocal();
    final now = DateTime.now();

    DateTime startDate = DateTime(oldestEntryDate.year, oldestEntryDate.month - 1, 1);
    DateTime endDate = DateTime(now.year, now.month, 1);

    List<DateTime> monthsToDisplay = [];
    DateTime currentCursor = endDate;
    while (!currentCursor.isBefore(startDate)) {
      monthsToDisplay.add(currentCursor);
      currentCursor = DateTime(currentCursor.year, currentCursor.month - 1, 1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: monthsToDisplay.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final monthDate = monthsToDisplay[index];
          return _MonthView(
            monthDate: monthDate,
            entriesByDate: entriesByDate,
            onDayTap: (date, entry) => _handleDayTap(context, date, entry),
          );
        },
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  final DateTime monthDate;
  final Map<DateTime, WeightEntryModel> entriesByDate;
  final Function(DateTime, WeightEntryModel?) onDayTap;

  const _MonthView({required this.monthDate, required this.entriesByDate, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final title = DateFormat('MMMM yyyy').format(monthDate);

    final isCurrentMonth = monthDate.year == now.year && monthDate.month == now.month;
    final daysInMonthTotal = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    final lastDayToShow = isCurrentMonth ? now.day : daysInMonthTotal;

    final firstWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday;
    final startOffset = firstWeekday - 1;

    // Generowanie siatki
    List<int?> cells = [];
    for (int i = 0; i < startOffset; i++) cells.add(null);
    for (int i = 1; i <= lastDayToShow; i++) cells.add(i);
    while (cells.length % 7 != 0) cells.add(null);

    List<List<int?>> rows = [];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(cells.sublist(i, i + 7));
    }

    // Odwrócona kolejność tygodni (najnowsze na górze siatki)
    rows = rows.reversed.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // 1. NAZWA MIESIĄCA (Na samej górze)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F465D).withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F465D),
                letterSpacing: 1.2,
              ),
            ),
          ),

          // 2. NAGŁÓWKI DNI TYGODNIA
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                  .map(
                    (day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          // 3. SIATKA DNI (Na dole)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: rows.map((weekRow) {
                return Row(
                  children: weekRow.map((dayNumber) {
                    if (dayNumber != null) {
                      final currentDate = DateTime(monthDate.year, monthDate.month, dayNumber);
                      final entry = entriesByDate[currentDate];

                      return Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: InkWell(
                            onTap: () => onDayTap(currentDate, entry),
                            borderRadius: BorderRadius.circular(8),
                            child: _DayCell(
                              dayNumber: dayNumber,
                              weight: entry?.weight,
                              isToday: DateUtils.isSameDay(currentDate, now),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Expanded(child: SizedBox.shrink());
                    }
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int dayNumber;
  final double? weight;
  final bool isToday;

  const _DayCell({required this.dayNumber, this.weight, this.isToday = false});

  @override
  Widget build(BuildContext context) {
    final hasWeight = weight != null;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFF0F465D).withOpacity(0.05)
            : (hasWeight ? Colors.grey.shade50 : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: const Color(0xFF0F465D).withOpacity(0.3))
            : (hasWeight ? Border.all(color: Colors.grey.shade200) : null),
      ),
      child: Stack(
        children: [
          // Numer dnia (na dole)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                dayNumber.toString(),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          // Waga (na środku)
          if (hasWeight)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  weight.toString(),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F465D)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
