import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_entity.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';

class ProductCard extends StatelessWidget {
  final MealProductModel mealProduct;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const ProductCard({super.key, required this.mealProduct, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            children: [
              Text(mealProduct.name),
              SizedBox(width: 10),
              // Text('Kcal: ${mealProduct.totalKcal ?? 'null'}'),
            ],
          ),
        ),
      ),
    );
  }
}
