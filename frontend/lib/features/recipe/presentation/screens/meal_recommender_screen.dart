import 'package:flutter/material.dart';
import 'package:frontend/features/recipe/data/recipe_model.dart';
import 'package:frontend/features/recipe/presentation/screens/create_recipe_screen.dart';
import 'package:frontend/features/recipe/presentation/screens/recipe_display_page.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_list_card.dart'; // Import this
import 'package:frontend/features/recipe/services/recipe_service.dart';
import 'package:provider/provider.dart';

class MealRecommenderScreen extends StatefulWidget {
  const MealRecommenderScreen({super.key});

  @override
  State<MealRecommenderScreen> createState() => _MealRecommenderScreenState();
}

class _MealRecommenderScreenState extends State<MealRecommenderScreen> {
  List<RecipeModel> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final service = Provider.of<RecipeService>(context, listen: false);
    final recipes = await service.getSavedRecipes();
    if (mounted) {
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRecipeScreen()),
    );
    _loadRecipes();
  }

  Future<void> _navigateToDetail(RecipeModel recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDisplayPage(recipe: recipe, isSaved: true),
      ),
    );

    if (result == true) {
      _loadRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Meal Recommender', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRecipes,
              child: _recipes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return RecipeListCard(
                          recipe: recipe,
                          onTap: () => _navigateToDetail(recipe),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.restaurant_menu),
        label: const Text('Create Recipe'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No recipes yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create one using AI!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}