import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/features/dashboard/presentation/screens/weight_history_chart.dart';
import 'package:frontend/features/weight_log/presentation/widgets/current_weight_card.dart';

class WeightLogHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight; // Np. 450.0
  final double collapsedHeight; // Np. 180.0
  final String rebuildKey;

  WeightLogHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.rebuildKey,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double shrinkPercent = math.min(1.0, shrinkOffset / (expandedHeight - collapsedHeight));

    final double chartOpacity = (1.0 - (shrinkPercent * 1.5)).clamp(0.0, 1.0);

    final double currentWeightHeight = Tween<double>(
      begin: collapsedHeight, // <--- TUTAJ BYŁ BŁĄD (jeśli było expandedHeight)
      end: collapsedHeight,
    ).transform(shrinkPercent);

    return Container(
      color: Colors.grey[50],
      child: Stack(
        fit: StackFit.expand,
        children: [
          // WARSTWA 1: WYKRES (Pod spodem)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            // Wykres zaczyna się tam, gdzie kończy się waga, więc nic na niego nie nachodzi
            top: currentWeightHeight,
            child: Opacity(
              opacity: chartOpacity,
              // IgnorePointer blokuje kliknięcia tylko gdy wykres jest niewidoczny
              child: IgnorePointer(ignoring: chartOpacity == 0, child: WeightHistoryChart()),
            ),
          ),

          // WARSTWA 2: KARTA WAGI (Na wierzchu)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: currentWeightHeight,
            child: SingleChildScrollView(physics: NeverScrollableScrollPhysics(), child: CurrentWeightCard()),
          ),

          if (shrinkPercent > 0.1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey[50]!.withValues(alpha: 0.0), Colors.grey[50]!],
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
