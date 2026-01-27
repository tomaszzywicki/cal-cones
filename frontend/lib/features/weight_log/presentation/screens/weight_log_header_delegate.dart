import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/screens/weight_history_chart.dart';
import 'package:frontend/features/weight_log/presentation/widgets/current_weight_card.dart';

class WeightLogHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final String rebuildKey;

  WeightLogHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.rebuildKey,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Obliczamy aktualną wysokość całego nagłówka w zależności od scrolla
    final double currentFullHeight = math.max(minExtent, maxExtent - shrinkOffset);

    // Procent zwinięcia (0.0 - pełny, 1.0 - zwinięty)
    final double shrinkPercent = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Dynamiczna wysokość wykresu - reszta miejsca po odjęciu stałej wysokości karty wagi
    // Dodajemy clamp, żeby wysokość nie zeszła poniżej 0
    final double dynamicChartHeight = math.max(0.0, currentFullHeight - collapsedHeight);

    // Opacity może zostać, żeby wykres znikał trochę szybciej niż samo zwijanie (estetyka)
    final double chartOpacity = (1.0 - (shrinkPercent * 1.2)).clamp(0.0, 1.0);

    return Container(
      color: Colors.grey[50],
      child: Column(
        // Używamy Column zamiast Stack dla naturalnego układu wysokości
        children: [
          // KARTA WAGI - stała wysokość collapsedHeight
          SizedBox(
            height: collapsedHeight,
            child: const SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: CurrentWeightCard(),
            ),
          ),

          // WYKRES - dynamicznie zmniejszana wysokość
          if (dynamicChartHeight > 0)
            Expanded(
              child: Opacity(
                opacity: chartOpacity,
                child: ClipRect(
                  // Zapobiega wychodzeniu wykresu poza dostępny obszar (overflow)
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: expandedHeight - collapsedHeight,
                    minHeight: 0,
                    child: WeightHistoryChart(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant WeightLogHeaderDelegate oldDelegate) {
    return oldDelegate.expandedHeight != expandedHeight ||
        oldDelegate.collapsedHeight != collapsedHeight ||
        oldDelegate.rebuildKey != rebuildKey;
  }
}
