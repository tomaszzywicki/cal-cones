import 'package:flutter/material.dart';

class MacroSplitIndicator extends StatelessWidget {
  final Map<String, int>? split;
  final double width;

  const MacroSplitIndicator({super.key, this.split, this.width = 120});

  @override
  Widget build(BuildContext context) {
    if (split == null) return const SizedBox.shrink();

    // Pobieramy wartości, dbając o to, by suma była bazą dla proporcji
    final carbs = (split!['Carbs'] ?? split!['carbs'] ?? 0).toDouble();
    final protein = (split!['Protein'] ?? split!['protein'] ?? 0).toDouble();
    final fat = (split!['Fat'] ?? split!['fat'] ?? split!['Fats'] ?? split!['fats'] ?? 0).toDouble();
    final total = carbs + protein + fat;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      width: width,
      height: 12,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.grey[200]),
      child: Row(
        children: [
          Expanded(
            flex: carbs.round(),
            child: Container(color: Colors.green),
          ),
          Expanded(
            flex: protein.round(),
            child: Container(color: Colors.redAccent),
          ),
          Expanded(
            flex: fat.round(),
            child: Container(color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
