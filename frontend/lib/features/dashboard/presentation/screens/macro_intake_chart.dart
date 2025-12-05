import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MacroIntakeChart extends StatelessWidget {
  const MacroIntakeChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: BarChart(
          BarChartData(
            gridData: FlGridData(drawVerticalLine: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return Text(
                      days[value.toInt() % days.length],
                      style: TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}',
                      style: TextStyle(color: Colors.indigo, fontSize: 10, fontWeight: FontWeight.w400),
                    );
                  },
                  interval: 250,
                  reservedSize: 35,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: [
              BarChartGroupData(x: 0, barRods: makeMacroRods(2100, 2000, 540, 120, 80), barsSpace: 0.5),
              BarChartGroupData(x: 1, barRods: makeMacroRods(1820, 1500, 400, 100, 50)),
              BarChartGroupData(x: 2, barRods: makeMacroRods(2000, 2200, 500, 130, 70)),
              BarChartGroupData(x: 3, barRods: makeMacroRods(2200, 2100, 600, 140, 90)),
              BarChartGroupData(x: 4, barRods: makeMacroRods(1900, 1700, 450, 110, 60)),
              BarChartGroupData(x: 5, barRods: makeMacroRods(2500, 2300, 700, 150, 100)),
              BarChartGroupData(x: 6, barRods: makeMacroRods(2000, 1600, 400, 120, 50)),
            ],
            // borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}

List<BarChartRodData> makeMacroRods(
  double targetKcal,
  double kcal,
  double carbs,
  double protein,
  double fat,
) {
  Color colorKcal = Colors.blue;
  Color colorCarbs = Colors.green;
  Color colorProtein = Colors.red;
  Color colorFat = Colors.yellow;

  double totalMass = carbs + protein + fat;
  double carbsplit = totalMass == 0 ? 0 : (carbs / totalMass) * kcal;
  double proteinsplit = totalMass == 0 ? 0 : (protein / totalMass) * kcal;
  double fatsplit = totalMass == 0 ? 0 : (fat / totalMass) * kcal;

  List<BarChartRodData> rods = [
    kcal <= targetKcal
        ? BarChartRodData(
            toY: targetKcal,
            color: colorKcal,
            borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
            rodStackItems: [
              BarChartRodStackItem(0, kcal, Colors.blue),
              BarChartRodStackItem(kcal, targetKcal, Colors.blue.shade200),
            ],
          )
        : BarChartRodData(
            toY: kcal,
            color: colorKcal,
            // borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
            rodStackItems: [
              BarChartRodStackItem(
                0,
                targetKcal,
                Colors.blue,
                borderSide: BorderSide(color: Colors.grey.shade800),
              ),
              BarChartRodStackItem(targetKcal, kcal, Colors.red.shade200),
            ],
          ),
    BarChartRodData(
      toY: kcal,
      borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
      rodStackItems: [
        BarChartRodStackItem(0, carbsplit, colorCarbs),
        BarChartRodStackItem(carbsplit, carbsplit + proteinsplit, colorProtein),
        BarChartRodStackItem(carbsplit + proteinsplit, carbsplit + proteinsplit + fatsplit, colorFat),
      ],
    ),
  ];

  return rods;
}
