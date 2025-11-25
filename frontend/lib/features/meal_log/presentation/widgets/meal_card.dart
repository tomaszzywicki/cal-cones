import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_entity.dart';

class MealCard extends StatelessWidget {
  final MealEntity meal;
  final VoidCallback onTap;
  const MealCard({super.key, required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Row(
            children: [
              Text(meal.name ?? 'No name'),
              SizedBox(width: 10),
              Text('Kcal: ${meal.totalKcal ?? 'null'}'),
            ],
          ),
        ),
      ),
    );
  }
}
