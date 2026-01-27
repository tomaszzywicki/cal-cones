import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/goal/services/daily_target_service.dart';
import 'package:frontend/features/meal/services/meal_service.dart';

class MacroIntakeChart extends StatefulWidget {
  const MacroIntakeChart({super.key});

  @override
  State<MacroIntakeChart> createState() => _MacroIntakeChartState();
}

class _MacroIntakeChartState extends State<MacroIntakeChart> {
  bool _isLoading = true;
  List<_DailyData> _weeklyData = [];
  double _maxY = 2500;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nasłuchiwanie zmian w MealService - każda zmiana w serwisie odświeży wykres
    context.watch<MealService>();
    _loadData();
  }

  Future<void> _loadData() async {
    final mealService = context.read<MealService>();
    final targetService = context.read<DailyTargetService>();

    final List<_DailyData> loadedData = [];
    final now = DateTime.now();
    double currentMax = 2000;

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final products = await mealService.getMealProductsForDate(date);
      final target = await targetService.getDailyTargetForDate(date);

      double kcal = 0, carbs = 0, protein = 0, fat = 0;
      for (var p in products) {
        kcal += p.kcal;
        carbs += p.carbs;
        protein += p.protein;
        fat += p.fat;
      }

      final targetKcal = target?.calories.toDouble() ?? 2000;
      if (kcal > currentMax) currentMax = kcal;
      if (targetKcal > currentMax) currentMax = targetKcal;

      loadedData.add(
        _DailyData(
          date: date,
          consumedKcal: kcal,
          targetKcal: targetKcal,
          carbs: carbs,
          protein: protein,
          fat: fat,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _weeklyData = loadedData;
        _maxY = (currentMax * 1.15).roundToDouble();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _weeklyData.isEmpty) {
      return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Padding(
        //   padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
        //   child: Text(
        //     "Last Seven Days",
        //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
        //   ),
        // ),
        SizedBox(
          height: 250, // Stała wysokość zapobiega pustym przestrzeniom i overflow
          child: BarChart(
            BarChartData(
              maxY: _maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 500,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.indigo.withOpacity(0.9),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final data = _weeklyData[groupIndex];
                    final dateStr = DateFormat('MMM dd').format(data.date);
                    return BarTooltipItem(
                      '$dateStr\n${rod.toY.round()} kcal',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index < 0 || index >= _weeklyData.length) return const SizedBox();
                      String label = DateFormat('E').format(_weeklyData[index].date);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: 500,
                    getTitlesWidget: (value, meta) =>
                        Text('${value.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: _weeklyData.asMap().entries.map((entry) {
                return BarChartGroupData(x: entry.key, barRods: _makeMacroRods(entry.value), barsSpace: 4);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartRodData> _makeMacroRods(_DailyData data) {
    const colorKcal = Colors.blue;
    const colorCarbs = Colors.green;
    const colorProtein = Colors.red;
    const colorFat = Colors.orange;

    double totalMacros = data.carbs + data.protein + data.fat;
    double carbsSplit = totalMacros == 0 ? 0 : (data.carbs / totalMacros) * data.consumedKcal;
    double proteinSplit = totalMacros == 0 ? 0 : (data.protein / totalMacros) * data.consumedKcal;
    double fatSplit = totalMacros == 0 ? 0 : (data.fat / totalMacros) * data.consumedKcal;

    return [
      BarChartRodData(
        toY: data.consumedKcal > data.targetKcal ? data.consumedKcal : data.targetKcal,
        width: 10,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        rodStackItems: [
          BarChartRodStackItem(0, data.consumedKcal.clamp(0, data.targetKcal), colorKcal),
          if (data.consumedKcal > data.targetKcal)
            BarChartRodStackItem(data.targetKcal, data.consumedKcal, Colors.redAccent.withOpacity(0.8))
          else
            BarChartRodStackItem(data.consumedKcal, data.targetKcal, colorKcal.withOpacity(0.1)),
        ],
      ),
      BarChartRodData(
        toY: data.consumedKcal > 0 ? data.consumedKcal : 0,
        width: 10,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        rodStackItems: data.consumedKcal > 0
            ? [
                BarChartRodStackItem(0, carbsSplit, colorCarbs),
                BarChartRodStackItem(carbsSplit, carbsSplit + proteinSplit, colorProtein),
                BarChartRodStackItem(
                  carbsSplit + proteinSplit,
                  carbsSplit + proteinSplit + fatSplit,
                  colorFat,
                ),
              ]
            : [],
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
