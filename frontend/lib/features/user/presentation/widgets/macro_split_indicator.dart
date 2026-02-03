import 'package:flutter/material.dart';

class MacroSplitIndicator extends StatelessWidget {
  final Map<String, int>? split;
  final double width;

  const MacroSplitIndicator({super.key, this.split, this.width = 130});

  @override
  Widget build(BuildContext context) {
    if (split == null) return const SizedBox.shrink();

    final carbs = (split!['Carbs'] ?? split!['carbs'] ?? 0).toDouble();
    final protein = (split!['Protein'] ?? split!['protein'] ?? 0).toDouble();
    final fat = (split!['Fat'] ?? split!['fat'] ?? split!['Fats'] ?? split!['fats'] ?? 0).toDouble();
    final total = carbs + protein + fat;

    if (total == 0) return const SizedBox.shrink();

    // Promień zaokrąglenia mniejszy niż połowa wysokości (np. 4px przy wysokości 14px)
    const double borderRadius = 3.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: width,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              // Cień zewnętrzny - daje efekt głębi pod paskiem
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              children: [
                // Tło i segmenty
                Row(
                  children: [
                    if (carbs > 0) _build3DSegment(carbs.round(), Colors.green), // Mocny zielony
                    if (protein > 0) _build3DSegment(protein.round(), Colors.red), // Mocny czerwony
                    if (fat > 0) _build3DSegment(fat.round(), Colors.amber), // Wyrazisty pomarańcz/żółty
                  ],
                ),
                // Warstwa nabłyszczająca (Górna krawędź - efekt światła)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.0)],
                      ),
                    ),
                  ),
                ),
                // Dolny cień wewnętrzny (efekt wyoblenia na dole)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.2), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _build3DSegment(int flexValue, Color color) {
    return Expanded(
      flex: flexValue,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border(
            // Ciemniejsza kreska z prawej strony każdego segmentu dla separacji
            right: BorderSide(color: Colors.black.withOpacity(0.1), width: 1.5),
          ),
        ),
      ),
    );
  }
}
