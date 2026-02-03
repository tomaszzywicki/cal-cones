import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';

class RecipeIngredientCard extends StatelessWidget {
  final MealProductModel mealProduct;
  final VoidCallback onRemove;

  const RecipeIngredientCard({
    super.key,
    required this.mealProduct,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    mealProduct.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Macros
                  Text(
                    '${mealProduct.kcal} kcal  •  C: ${mealProduct.carbs.toStringAsFixed(0)}g  P: ${mealProduct.protein.toStringAsFixed(0)}g  F: ${mealProduct.fat.toStringAsFixed(0)}g',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Amount Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${mealProduct.amount.toStringAsFixed(0)} ${mealProduct.unitShort}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),

            // Delete Button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(), // Reduces padding area
              iconSize: 22,
            ),
          ],
        ),
      ),
    );
  }
}