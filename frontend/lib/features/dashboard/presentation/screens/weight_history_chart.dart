import 'dart:math'; // Potrzebne do pow()
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/goal/services/goal_service.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

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

  // Przechowujemy Future w zmiennej, aby uniknąć lagów (identycznie jak w CurrentGoalCard)
  Future<GoalModel?>? _activeGoalFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Watch zapewnia, że gdy GoalService wywoła notifyListeners(),
    // didChangeDependencies odpali się ponownie i zaktualizuje Future.
    final goalService = context.watch<GoalService>();
    _activeGoalFuture = goalService.getActiveGoal();
  }

  double roundWithDecimals(double value, int decimals) {
    double mod = pow(10.0, decimals).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }

  DateTime _getStartTime(List<dynamic> entries) {
    if (_selectedPeriod.duration == null) {
      if (entries.isEmpty) return DateTime.now();
      final oldest = entries.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
      return DateTime(oldest.year, oldest.month, oldest.day);
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(_selectedPeriod.duration!);
  }

  List<FlSpot> _processData(List<dynamic> entries, DateTime startTime) {
    final filtered = entries
        .where((e) => e.date.isAfter(startTime) || e.date.isAtSameMomentAs(startTime))
        .toList();
    if (filtered.isEmpty) return [];

    if (_selectedPeriod.index >= ChartPeriod.threeMonths.index) {
      final grouped = groupBy(filtered, (dynamic e) {
        final daysDiff = e.date.difference(startTime).inDays;
        return daysDiff ~/ 7;
      });

      final List<FlSpot> aggregatedSpots = [];
      grouped.forEach((weekIndex, weekEntries) {
        final weights = weekEntries.map((e) => (e.weight as num).toDouble());
        final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
        aggregatedSpots.add(FlSpot(weekIndex * 7.0 + 3.5, roundWithDecimals(avgWeight, 1)));
      });
      return aggregatedSpots..sort((a, b) => a.x.compareTo(b.x));
    }

    return filtered.map((e) {
      final x = e.date.difference(startTime).inDays.toDouble();
      return FlSpot(x, e.weight.toDouble());
    }).toList()..sort((a, b) => a.x.compareTo(b.x));
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final weightEntries = weightLogService.entries;
    final startTime = _getStartTime(weightEntries);
    final spots = _processData(weightEntries, startTime);

    return FutureBuilder<GoalModel?>(
      future: _activeGoalFuture,
      builder: (context, snapshot) {
        final activeGoal = snapshot.data;

        // --- OŚ X: Minimalny margines poziomy ---
        final double baseMaxX =
            _selectedPeriod.duration?.inDays.toDouble() ??
            (DateTime.now().difference(startTime).inDays.toDouble().clamp(1, 10000) + 1);
        final double horizontalOffset = baseMaxX * 0.01;

        // --- OŚ Y: Obliczanie zakresu z uwzględnieniem celu ---
        List<double> yValues = spots.map((s) => s.y).toList();

        if (activeGoal != null) {
          if (!(activeGoal.isMaintenanceMode)) {
            yValues.add(activeGoal.startWeight);
            yValues.add(activeGoal.targetWeight);
          } else {
            yValues.add(activeGoal.targetWeight + 0.5);
            yValues.add(activeGoal.targetWeight - 0.5);
          }
        }

        double minY = 0;
        double maxY = 100;

        if (yValues.isNotEmpty) {
          final minVal = yValues.reduce((a, b) => a < b ? a : b);
          final maxVal = yValues.reduce((a, b) => a > b ? a : b);
          final range = maxVal - minVal;

          final margin = (range * 0.02).clamp(0.5, 1.5);

          minY = (minVal - margin).floorToDouble();
          maxY = (maxVal + margin).ceilToDouble();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ChartPeriod.values.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ChoiceChip(
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        label: Center(
                          child: Text(
                            period.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedPeriod = period),
                        selectedColor: Colors.black,
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 280,
                child: LineChart(
                  LineChartData(
                    minX: -horizontalOffset,
                    maxX: baseMaxX + horizontalOffset,
                    minY: minY,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Colors.black,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                          final date = startTime.add(Duration(days: s.x.toInt()));
                          final isAvg = _selectedPeriod.index >= ChartPeriod.threeMonths.index;

                          return LineTooltipItem(
                            '${s.y} kg${isAvg ? ' (Avg)' : ''}\n',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            children: [
                              TextSpan(
                                text: isAvg
                                    ? '${DateFormat('MMM d').format(date.subtract(Duration(days: date.weekday - 1)))} - ${DateFormat('MMM d').format(date.add(Duration(days: 7 - date.weekday)))}'
                                    : DateFormat('EEEE, MMM d').format(date),
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.15,
                        preventCurveOverShooting: true,
                        barWidth: 3,
                        color: Colors.black,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: _selectedPeriod.index >= ChartPeriod.threeMonths.index ? 3 : 2,
                            color: Colors.black,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.03), Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) => Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: (baseMaxX / 4).clamp(1, 365),
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value > baseMaxX) return const SizedBox.shrink();
                            final date = startTime.add(Duration(days: value.toInt()));
                            return Column(
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  _selectedPeriod == ChartPeriod.week
                                      ? DateFormat('E').format(date)
                                      : DateFormat('MMM d').format(date),
                                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    extraLinesData: ExtraLinesData(horizontalLines: _buildHorizontalLines(activeGoal)),
                    rangeAnnotations: RangeAnnotations(
                      horizontalRangeAnnotations: _buildMaintenanceRange(activeGoal),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<HorizontalLine> _buildHorizontalLines(GoalModel? activeGoal) {
    if (activeGoal == null || activeGoal.isMaintenanceMode) return [];

    return [
      HorizontalLine(
        y: activeGoal.startWeight,
        color: Colors.red.withOpacity(0.5),
        strokeWidth: 1.2,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topLeft,
          labelResolver: (line) => 'Start: ${roundWithDecimals(line.y, 1)}kg',
          style: TextStyle(color: Colors.red.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
      HorizontalLine(
        y: activeGoal.targetWeight,
        color: Colors.green.withOpacity(0.5),
        strokeWidth: 1.2,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          labelResolver: (line) => 'Goal: ${roundWithDecimals(line.y, 1)}kg',
          style: TextStyle(color: Colors.green.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
    ];
  }

  List<HorizontalRangeAnnotation> _buildMaintenanceRange(GoalModel? activeGoal) {
    if (activeGoal == null || !activeGoal.isMaintenanceMode) return [];

    return [
      HorizontalRangeAnnotation(
        y1: activeGoal.targetWeight - 1.0,
        y2: activeGoal.targetWeight + 1.0,
        color: Colors.green.withOpacity(0.05),
      ),
    ];
  }
}
