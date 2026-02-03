import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_product_entity.dart';

class MealProductCard extends StatelessWidget {
  final MealProductEntity mealProduct;
  final VoidCallback? onTap;
  final VoidCallback? onEditAmount;
  const MealProductCard({super.key, required this.mealProduct, this.onTap, this.onEditAmount});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
        child: ListTile(
          title: Text(mealProduct.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          subtitle: Text(
            '${mealProduct.kcal} Kcal  ${mealProduct.protein.toInt()}P  ${mealProduct.carbs.toInt()}C  ${mealProduct.fat.toInt()}F',
          ),
          trailing: TextButton(
            onPressed: onEditAmount,
            child: Text(
              '${mealProduct.amount}${mealProduct.unitShort}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
