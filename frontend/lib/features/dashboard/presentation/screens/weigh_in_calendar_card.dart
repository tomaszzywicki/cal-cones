import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';

class WeighInCalendarCard extends StatelessWidget {
  const WeighInCalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final now = DateTime.now();

    // Obliczamy datę początkową (cofamy się o 2 tygodnie + dni od początku tygodnia)
    final startDate = now.subtract(Duration(days: (now.weekday - 1) + 14));

    // Generujemy 21 kafelków
    final List<DateTime> calendarDays = List.generate(21, (index) {
      return startDate.add(Duration(days: index));
    });

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Your Weigh-Ins", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 7,
              crossAxisSpacing: 2.0, // Mniejsze odstępy
              mainAxisSpacing: 2.0, // Mniejsze odstępy
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.0,
              children: calendarDays.map((date) {
                final isFuture = date.difference(now).inDays > 0 && date.day != now.day;
                final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

                // Dla dni przyszłych nie sprawdzamy bazy
                final isFilled = !isFuture && weightLogService.entryExistsWithDate(date);

                return _DayTile(isFilled: isFilled, isToday: isToday, isFuture: isFuture);
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Dni tygodnia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  final bool isFilled;
  final bool isToday;
  final bool isFuture;

  const _DayTile({super.key, required this.isFilled, required this.isToday, required this.isFuture});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Border? border;

    if (isFuture) {
      // Dni przyszłe - jasnoszare, bez ramki
      bgColor = Colors.grey.shade200;
      border = Border.all(color: Colors.grey.shade300, width: 1.0);
    } else if (isFilled) {
      // Sukces - zielony
      bgColor = Colors.green;
    } else {
      // Przeszłość/Dziś bez wpisu - ciemniejszy szary
      bgColor = Colors.grey.shade300;

      // Jeśli to przeszłość (nie dziś) i brak wpisu -> czerwona ramka
      if (!isToday) {
        border = Border.all(color: Colors.red.withOpacity(0.3), width: 1.5);
      }
    }

    return Container(
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4.0), border: border),
      child: isToday
          ? Transform.translate(
              offset: const Offset(0, 8),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.blue, // Niebieska kropka dla dzisiaj
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
