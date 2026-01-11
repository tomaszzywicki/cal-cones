import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// Pamiętaj o importach Twoich widżetów:
import 'package:frontend/features/dashboard/presentation/screens/weight_history_chart.dart';
import 'package:frontend/features/weight_log/presentation/widgets/current_weight_card.dart';

class WeightLogHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight; // Maksymalna wysokość (Waga + Wykres)
  final double collapsedHeight; // Minimalna wysokość (Tylko ściśnięta Waga)

  WeightLogHeaderDelegate({required this.expandedHeight, required this.collapsedHeight});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Obliczamy procent zwinięcia (0.0 = pełny, 1.0 = zwinięty)
    final double shrinkPercent = math.min(1.0, shrinkOffset / (expandedHeight - collapsedHeight));

    // WYKRES: Ma zanikać (Opacity). Zanika szybciej niż zwija się nagłówek.
    final double chartOpacity = (1.0 - (shrinkPercent * 2)).clamp(0.0, 1.0);

    // WAGA: Ma się zmniejszać.
    // Pełna wysokość karty wagi to np. 160, a chcemy ją ścisnąć do collapsedHeight (np. 100).
    // Możemy manipulować paddingiem lub transformacją.

    return Container(
      color: Colors.grey[50], // Tło nagłówka
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. WYKRES (Na dole, zanika)
          // Ustawiamy go nieco niżej, żeby robił miejsce dla karty wagi
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // Margines od dołu
            top: collapsedHeight, // Zaczyna się pod złożoną kartą wagi
            child: Opacity(opacity: chartOpacity, child: WeightHistoryChart()),
          ),

          // 2. KARTA WAGI (Na górze, zawsze widoczna, ale zmienia rozmiar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: null, // Wysokość sterowana constraints
            child: SizedBox(
              // Płynna zmiana wysokości kontenera wagi
              height: Tween<double>(
                begin: expandedHeight, // Startowa wysokość karty (duża)
                end: collapsedHeight, // Końcowa wysokość (mała)
              ).transform(shrinkPercent),
              child: const SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(), // Blokujemy scroll wewnątrz karty
                child: CurrentWeightCard(),
              ),
            ),
          ),

          // Opcjonalnie: Biały gradient na dole, żeby ładnie ucinało wykres przy zwijaniu
          // if (shrinkPercent > 0.1)
          //   Positioned(
          //     bottom: 0,
          //     left: 0,
          //     right: 0,
          //     height: 20,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           begin: Alignment.topCenter,
          //           end: Alignment.bottomCenter,
          //           colors: [Colors.grey[50]!.withOpacity(0.0), Colors.grey[50]!],
          //         ),
          //       ),
          //     ),
          //   ),
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
    return oldDelegate.expandedHeight != expandedHeight || oldDelegate.collapsedHeight != collapsedHeight;
  }
}
