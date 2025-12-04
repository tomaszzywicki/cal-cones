import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeightHistoryChart extends StatelessWidget {
  const WeightHistoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 76),
                  FlSpot(1, 75.5),
                  FlSpot(2, 75),
                  FlSpot(3, 75.5),
                  FlSpot(4, 75),
                  FlSpot(5, 74.5),
                  FlSpot(6, 74.6),
                  FlSpot(7, 74.2),
                  FlSpot(8, 74),
                  FlSpot(9, 73.9),
                  FlSpot(10, 74),
                  FlSpot(11, 74.1),
                  FlSpot(12, 74),
                  FlSpot(13, 74.1),
                  FlSpot(14, 73.8),
                ],
                isCurved: true,
                barWidth: 3,
                color: Colors.indigo,
                // dotData: FlDotData(show: false),
              ),
            ],

            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 75.8,
                  color: Colors.red,
                  strokeWidth: 2,
                  dashArray: [5, 5],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                    labelResolver: (line) => 'Starting Weight',
                  ),
                ),
                HorizontalLine(
                  y: 74,
                  color: Colors.green,
                  strokeWidth: 2,
                  dashArray: [5, 5],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.bottomLeft,
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                    labelResolver: (line) => 'Target Weight',
                  ),
                ),
              ],
            ),

            // : HorizontalLine(y: 75, color: Colors.red, strokeWidth: 2),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 0.5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toStringAsFixed(1)}',
                      style: TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
