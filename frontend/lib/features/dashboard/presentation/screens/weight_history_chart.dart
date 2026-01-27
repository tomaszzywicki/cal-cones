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

  // Oblicza pozycję na osi X w zależności od wybranego okresu czasu
  List<FlSpot> _getFilteredSpots(List<dynamic> entries) {
    if (entries.isEmpty) return [];

    final now = DateTime.now();
    final startTime = _selectedPeriod.duration == null
        ? (entries.isEmpty ? now : entries.first.date as DateTime)
        : now.subtract(_selectedPeriod.duration!);

    final filteredEntries = entries.where((entry) => entry.date.isAfter(startTime)).toList();

    if (filteredEntries.isEmpty) return [];

    return filteredEntries.map((entry) {
      // X to liczba dni od punktu startowego wybranego okresu
      final xValue = entry.date.difference(startTime).inDays.toDouble();
      return FlSpot(xValue, entry.weight.toDouble());
    }).toList();
  }

  double _getYInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1.0;
    final range = _getYMax(spots) - _getYMin(spots);
    if (range <= 5) return 1.0;
    if (range <= 15) return 2.0;
    return 5.0;
  }

  // Dodaje zapas (padding) do skali Y
  double _getYMin(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    final minWeight = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    return (minWeight - 2).floorToDouble();
  }

  double _getYMax(List<FlSpot> spots) {
    if (spots.isEmpty) return 100;
    final maxWeight = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    return (maxWeight + 2).ceilToDouble();
  }

  double _getXMax() {
    return _selectedPeriod.duration?.inDays.toDouble() ??
        (DateTime.now().difference(DateTime.now().subtract(const Duration(days: 365))).inDays.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final weightLogService = context.watch<WeightLogService>();
    final weightEntries = weightLogService.entries;
    final spots = _getFilteredSpots(weightEntries);

    // Maksymalna wartość X to długość trwania okresu w dniach
    final double maxX =
        _selectedPeriod.duration?.inDays.toDouble() ?? (spots.isEmpty ? 30 : spots.last.x + 5);

    return Column(
      children: [
        // Selektor okresu (bez zmian w logice, styl dopasowany do braku karty)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ChartPeriod.values.map((period) {
              final isSelected = _selectedPeriod == period;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(period.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedPeriod = period);
                  },
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: isSelected ? Colors.black : Colors.grey.shade300),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),
        // Wykres wylewa się bezpośrednio na tło (bez Card)
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.only(right: 20, left: 10),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: _getYMin(spots),
                maxY: _getYMax(spots),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    // Poprawione wygładzanie
                    curveSmoothness: 0.35,
                    preventCurveOverShooting: true,
                    barWidth: 4,
                    color: Colors.black,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.black,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.0)],
                      ),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: _getYInterval(spots),
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: maxX / 4, // Wyświetla ok. 4 etykiety czasowe
                      getTitlesWidget: (value, meta) {
                        // Można tu dodać formatowanie dat, na razie puste dla czystości
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => Colors.black,
                    getTooltipItems: (spots) => spots
                        .map(
                          (s) => LineTooltipItem(
                            '${s.y} kg',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
