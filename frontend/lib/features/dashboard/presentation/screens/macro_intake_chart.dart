import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/goal/services/daily_target_service.dart';
import 'package:frontend/features/meal/services/meal_service.dart';

enum MacroType { calories, protein, carbs, fat }

class MacroIntakeChart extends StatefulWidget {
  const MacroIntakeChart({super.key});

  @override
  State<MacroIntakeChart> createState() => _MacroIntakeChartState();
}

class _MacroIntakeChartState extends State<MacroIntakeChart> {
  bool _isLoading = true;
  List<_DailyData> _weeklyData = [];
  double _maxY = 100;
  MacroType _selectedType = MacroType.calories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    // Używamy read zamiast watch wewnątrz metody asynchronicznej
    final mealService = context.read<MealService>();
    final targetService = context.read<DailyTargetService>();

    final List<_DailyData> loadedData = [];
    final now = DateTime.now();
    double currentMax = 0;

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));

      final products = await mealService.getMealProductsForDate(date);
      final target = await targetService.getDailyTargetForDate(date);

      double kcal = 0, carbs = 0, protein = 0, fat = 0;
      for (var p in products) {
        kcal += p.kcal;
        carbs += p.carbs;
        protein += p.protein;
        fat += p.fat;
      }

      final dayData = _DailyData(
        date: date,
        consumedKcal: kcal,
        targetKcal: target?.calories.toDouble() ?? 2000,
        carbs: carbs,
        targetCarbs: target?.carbsG.toDouble() ?? 200,
        protein: protein,
        targetProtein: target?.proteinG.toDouble() ?? 150,
        fat: fat,
        targetFat: target?.fatG.toDouble() ?? 70,
      );

      // Sprawdzamy wartości dla aktualnie wybranego typu, aby wyliczyć skalę
      double consumedVal = _getVal(dayData, _selectedType, isTarget: false);
      double targetVal = _getVal(dayData, _selectedType, isTarget: true);

      if (consumedVal > currentMax) currentMax = consumedVal;
      if (targetVal > currentMax) currentMax = targetVal;

      loadedData.add(dayData);
    }

    if (mounted) {
      setState(() {
        _weeklyData = loadedData;
        // Obliczanie górnej granicy z 15% zapasem
        if (currentMax == 0) {
          // Wartości domyślne dla pustego wykresu
          _maxY = _selectedType == MacroType.calories ? 2500 : 200;
        } else {
          _maxY = currentMax * 1.15;
        }
        _isLoading = false;
      });
    }
  }

  double _getVal(_DailyData data, MacroType type, {required bool isTarget}) {
    switch (type) {
      case MacroType.calories:
        return isTarget ? data.targetKcal : data.consumedKcal;
      case MacroType.protein:
        return isTarget ? data.targetProtein : data.protein;
      case MacroType.carbs:
        return isTarget ? data.targetCarbs : data.carbs;
      case MacroType.fat:
        return isTarget ? data.targetFat : data.fat;
    }
  }

  Color _getSelectedColor() {
    switch (_selectedType) {
      case MacroType.calories:
        return Colors.blue;
      case MacroType.protein:
        return Colors.red;
      case MacroType.carbs:
        return Colors.green;
      case MacroType.fat:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _weeklyData.isEmpty) {
      return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              BarChart(
                BarChartData(
                  maxY: _maxY,
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (val) =>
                        FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, m) =>
                            Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int i = value.toInt();
                          if (i < 0 || i >= _weeklyData.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('E').format(_weeklyData[i].date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: _weeklyData.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: _getVal(e.value, _selectedType, isTarget: false),
                          color: _getSelectedColor(),
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              IgnorePointer(
                child: LineChart(
                  LineChartData(
                    maxY: _maxY,
                    minY: 0,
                    minX: -1.23,
                    maxX: 6.5,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _weeklyData.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), _getVal(e.value, _selectedType, isTarget: true));
                        }).toList(),
                        isCurved: false,
                        dashArray: [5, 5],
                        color: Colors.grey.withOpacity(0.6),
                        barWidth: 2,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, p, bar, i) => FlDotCirclePainter(
                            radius: 3,
                            color: Colors.grey,
                            strokeColor: Colors.white,
                            strokeWidth: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _macroSelector("Calories", MacroType.calories, Colors.blue),
        _macroSelector("Protein", MacroType.protein, Colors.red),
        _macroSelector("Carbs", MacroType.carbs, Colors.green),
        _macroSelector("Fat", MacroType.fat, Colors.orange),
      ],
    );
  }

  Widget _macroSelector(String label, MacroType type, Color color) {
    bool isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12)),
      selected: isSelected,
      selectedColor: color,
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedType = type;
            _isLoading = true;
          });
          _loadData();
        }
      },
    );
  }
}

class _DailyData {
  final DateTime date;
  final double consumedKcal, targetKcal, carbs, targetCarbs, protein, targetProtein, fat, targetFat;
  _DailyData({
    required this.date,
    required this.consumedKcal,
    required this.targetKcal,
    required this.carbs,
    required this.targetCarbs,
    required this.protein,
    required this.targetProtein,
    required this.fat,
    required this.targetFat,
  });
}
