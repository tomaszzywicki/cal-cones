import 'package:flutter/material.dart';
import 'package:frontend/features/recipe/data/recipe_model.dart';
import 'package:frontend/features/recipe/presentation/screens/meal_recommender_screen.dart';
import 'package:frontend/features/recipe/services/recipe_service.dart';
import 'package:provider/provider.dart';

class RecipeDisplayPage extends StatefulWidget {
  final RecipeModel recipe;
  final bool isSaved;

  const RecipeDisplayPage({super.key, required this.recipe, this.isSaved = true});

  @override
  State<RecipeDisplayPage> createState() => _RecipeDisplayPageState();
}

class _RecipeDisplayPageState extends State<RecipeDisplayPage> {
  late RecipeModel _recipe;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  Future<void> _regenerateRecipe() async {
    setState(() => _isRegenerating = true);
    final service = Provider.of<RecipeService>(context, listen: false);

    try {
      // 1. Generate new recipe using existing ingredients
      // We pass "Meal" as a generic type since we want a variation using the same ingredients
      final newRecipeData = await service.generateRecipe(
        _recipe.ingredients, 
        "Meal",
        avoidRecipeName: _recipe.name,
      );

      // 2. Create updated model preserving the ID and creation date
      final updatedRecipe = RecipeModel(
        id: _recipe.id,
        name: newRecipeData.name,
        time: newRecipeData.time,
        calories: newRecipeData.calories,
        ingredients: newRecipeData.ingredients,
        instructions: newRecipeData.instructions,
        createdAt: _recipe.createdAt, // Preserve original date
      );

      // 3. Update in DB
      if (_recipe.id != null) {
        await service.updateRecipe(updatedRecipe);
      }

      // 4. Update UI
      if (mounted) {
        setState(() {
          _recipe = updatedRecipe;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to regenerate: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegenerating = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MealRecommenderScreen(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteRecipe,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _recipe.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.timer, size: 16),
                  label: Text(_recipe.time),
                  backgroundColor: Colors.grey[100],
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                  label: Text('${_recipe.calories} kcal'),
                  backgroundColor: Colors.orange.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Ingredients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _recipe.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(ing, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Instructions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._recipe.instructions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 40),

            // REGENERATE BUTTON
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isRegenerating ? null : _regenerateRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isRegenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh),
                      const SizedBox(width: 12), 
                      Text(
                        _isRegenerating ? 'Generating...' : 'Regenerate Recipe',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRecipe() async {
    // 1. Show Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // 2. Perform Delete if confirmed
    if (confirmed == true && _recipe.id != null) {
       final service = Provider.of<RecipeService>(context, listen: false);
       await service.deleteRecipe(_recipe.id!);
       
       if (mounted) {
         // Return 'true' to indicate list refresh needed
         Navigator.pop(context, true);
       }
    }
  }
}