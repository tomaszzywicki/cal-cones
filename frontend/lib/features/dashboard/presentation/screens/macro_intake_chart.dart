import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/goal/services/daily_target_service.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/goal/data/daily_target_model.dart';

class MacroIntakeChart extends StatefulWidget {
  const MacroIntakeChart({super.key});

  @override
  State<MacroIntakeChart> createState() => _MacroIntakeChartState();
}

class _MacroIntakeChartState extends State<MacroIntakeChart> {
  bool _isLoading = true;
  List<_DailyData> _weeklyData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final mealService = context.read<MealService>();
    final targetService = context.read<DailyTargetService>();

    final List<_DailyData> loadedData = [];
    final now = DateTime.now();

    // Pobieramy dane z ostatnich 7 dni (od 6 dni temu do dzisiaj)
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Pobieranie danych z serwisów
      final products = await mealService.getMealProductsForDate(date);
      final target = await targetService.getDailyTargetForDate(date);

      // Sumowanie makroskładników dla danego dnia
      double kcal = 0, carbs = 0, protein = 0, fat = 0;
      for (var p in products) {
        kcal += p.kcal;
        carbs += p.carbs;
        protein += p.protein;
        fat += p.fat;
      }

      loadedData.add(
        _DailyData(
          date: date,
          consumedKcal: kcal,
          targetKcal: target?.calories.toDouble() ?? 2000,
          carbs: carbs,
          protein: protein,
          fat: fat,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _weeklyData = loadedData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        color: Colors.white,
        child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ostatnie 7 dni", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= _weeklyData.length) return const SizedBox();
                          final days = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];
                          // Mapowanie dnia tygodnia (DateTime.weekday: 1-7)
                          String label = days[_weeklyData[index].date.weekday - 1];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: _weeklyData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: _makeMacroRods(entry.value),
                      barsSpace: 4,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartRodData> _makeMacroRods(_DailyData data) {
    const Color colorKcal = Colors.blue;
    const Color colorCarbs = Colors.green;
    const Color colorProtein = Colors.red;
    const Color colorFat = Colors.orange;

    // Obliczanie proporcji makroskładników w stosunku do spożytych kalorii
    double totalMacros = data.carbs + data.protein + data.fat;
    double carbsSplit = totalMacros == 0 ? 0 : (data.carbs / totalMacros) * data.consumedKcal;
    double proteinSplit = totalMacros == 0 ? 0 : (data.protein / totalMacros) * data.consumedKcal;
    double fatSplit = totalMacros == 0 ? 0 : (data.fat / totalMacros) * data.consumedKcal;

    return [
      // Słupek 1: Kalorie vs Cel
      BarChartRodData(
        toY: data.consumedKcal > data.targetKcal ? data.consumedKcal : data.targetKcal,
        width: 12,
        borderRadius: BorderRadius.circular(4),
        rodStackItems: [
          BarChartRodStackItem(0, data.consumedKcal.clamp(0, data.targetKcal), colorKcal),
          if (data.consumedKcal > data.targetKcal)
            BarChartRodStackItem(data.targetKcal, data.consumedKcal, Colors.redAccent.withOpacity(0.6))
          else
            BarChartRodStackItem(data.consumedKcal, data.targetKcal, colorKcal.withOpacity(0.1)),
        ],
      ),
      // Słupek 2: Podział Makroskładników (skalowany do spożytych kcal)
      BarChartRodData(
        toY: data.consumedKcal,
        width: 12,
        borderRadius: BorderRadius.circular(4),
        rodStackItems: [
          BarChartRodStackItem(0, carbsSplit, colorCarbs),
          BarChartRodStackItem(carbsSplit, carbsSplit + proteinSplit, colorProtein),
          BarChartRodStackItem(carbsSplit + proteinSplit, carbsSplit + proteinSplit + fatSplit, colorFat),
        ],
      ),
    ];
  }
}

class _DailyData {
  final DateTime date;
  final double consumedKcal;
  final double targetKcal;
  final double carbs;
  final double protein;
  final double fat;

  _DailyData({
    required this.date,
    required this.consumedKcal,
    required this.targetKcal,
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}
