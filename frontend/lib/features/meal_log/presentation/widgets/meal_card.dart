import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';

class ProductCard extends StatelessWidget {
  final MealProductModel mealProduct;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEditAmount;

  const ProductCard({
    super.key,
    required this.mealProduct,
    required this.onTap,
    required this.onLongPress,
    required this.onEditAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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

                    // Makro
                    Text(
                      '${mealProduct.kcal} kcal  •  C: ${mealProduct.carbs.toStringAsFixed(0)}g  P: ${mealProduct.protein.toStringAsFixed(0)}g  F: ${mealProduct.fat.toStringAsFixed(0)}g',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: onEditAmount,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${mealProduct.amount.toStringAsFixed(0)} ${mealProduct.unitShort}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
