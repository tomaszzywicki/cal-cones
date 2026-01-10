import 'package:flutter/material.dart';
import 'package:frontend/features/recipe/data/recipe_model.dart';

class RecipeListCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;

  const RecipeListCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
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
                      recipe.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Calories
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.calories} kcal',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Time Pill (Matches ProductCard amount style)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[800]),
                    const SizedBox(width: 4),
                    Text(
                      recipe.time,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}