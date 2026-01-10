import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/product/presentation/screens/product_search_page.dart';
import 'package:frontend/features/recipe/data/recipe_model.dart';
import 'package:frontend/features/recipe/presentation/screens/recipe_display_page.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_ingredient_card.dart'; // Import this
import 'package:frontend/features/recipe/services/recipe_service.dart';
import 'package:provider/provider.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final List<MealProductModel> _ingredients = [];
  String _selectedMealType = 'Lunch';
  bool _isGenerating = false;

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Recipe', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          // Meal Type Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                const Text('Meal Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedMealType,
                  dropdownColor: Colors.white,
                  underline: Container(height: 0),
                  items: _mealTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMealType = val);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Ingredients List
          Expanded(
            child: _ingredients.isEmpty
                ? Center(
                    child: Text(
                      'Add ingredients to start',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _ingredients.length,
                    itemBuilder: (context, index) {
                      final item = _ingredients[index];
                      return RecipeIngredientCard(
                        mealProduct: item,
                        onRemove: () {
                          setState(() {
                            _ingredients.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
          ),

          // Add Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openAddIngredient,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Ingredient'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Generate Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: ElevatedButton(
              onPressed: (_ingredients.isNotEmpty && !_isGenerating) ? _generateRecipe : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      height: 20, width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text('Generate Recipe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddIngredient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSearchPage(
          consumedAt: DateTime.now(),
          mode: ProductPageMode.addToRecipe, 
        ),
      ),
    );

    if (result != null && result['mealProduct'] != null) {
      setState(() {
        _ingredients.add(result['mealProduct'] as MealProductModel);
      });
    }
  }

  Future<void> _generateRecipe() async {
    setState(() => _isGenerating = true);
    final service = Provider.of<RecipeService>(context, listen: false);

    try {
      final ingredientNames = _ingredients.map((e) => "${e.name} (${e.amount}${e.unitShort})").toList();
      
      final recipe = await service.generateRecipe(ingredientNames, _selectedMealType);

      final int newId = await service.saveRecipe(recipe);

      final savedRecipe = RecipeModel(
        id: newId,
        name: recipe.name,
        time: recipe.time,
        calories: recipe.calories,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        createdAt: recipe.createdAt,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDisplayPage(recipe: savedRecipe, isSaved: true),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}