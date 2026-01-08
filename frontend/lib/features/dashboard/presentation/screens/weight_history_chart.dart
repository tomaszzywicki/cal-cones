import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

enum ChartPeriod {
  week('1W', Duration(days: 7)),
  month('1M', Duration(days: 30)),
  threeMonths('3M', Duration(days: 90)),
  sixMonths('6M', Duration(days: 180)),
  year('1Y', Duration(days: 365)),
  max('Max', null);

  final String label;
  final Duration? duration;
  const ChartPeriod(this.label, this.duration);
}

class WeightHistoryChart extends StatefulWidget {
  const WeightHistoryChart({super.key});

  @override
  State<WeightHistoryChart> createState() => _WeightHistoryChartState();
}

class _WeightHistoryChartState extends State<WeightHistoryChart> {
  ChartPeriod _selectedPeriod = ChartPeriod.month;

  List<FlSpot> _getFilteredSpots(List<dynamic> entries) {
    if (entries.isEmpty) return [];

    final now = DateTime.now();

    final filteredEntries = _selectedPeriod.duration == null
        ? entries
        : entries.where((entry) {
            return entry.date.isAfter(now.subtract(_selectedPeriod.duration!));
          }).toList();

    return filteredEntries.map((entry) {
      final timeOffset = entry.date.difference(filteredEntries.first.date).inDays.toDouble();
      return FlSpot(timeOffset, entry.weight.toDouble());
    }).toList();
  }

  double _getYInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1.0;

    final weights = spots.map((spot) => spot.y).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;

    if (range <= 5) {
      return 0.5;
    } else if (range <= 10) {
      return 1.0;
    } else if (range <= 20) {
      return 2.0;
    } else {
      return 5.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final weightEntries = weightLogService.entries;

    final spots = _getFilteredSpots(weightEntries);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ChartPeriod.values.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: ChoiceChip(
                      label: Text(period.label),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _selectedPeriod = period;
                          });
                        }
                      },
                      selectedColor: Colors.indigo,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? Colors.indigo : Colors.transparent),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      preventCurveOvershootingThreshold: 8,
                      curveSmoothness: 0.6,
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
                        interval: _getYInterval(spots),
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
          ],
        ),
      ),
    );
  }
}
