import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/ai/presentation/screens/ai_detected_products_page.dart';
import 'package:frontend/features/ai/services/ai_service.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/presentation/screens/product_search_page.dart';
import 'package:frontend/features/recipe/data/recipe_model.dart';
import 'package:frontend/features/recipe/presentation/screens/recipe_display_page.dart';
import 'package:frontend/features/recipe/presentation/widgets/recipe_ingredient_card.dart';
import 'package:frontend/features/recipe/services/recipe_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final List<MealProductModel> _ingredients = [];
  late String _selectedMealType;
  bool _isGenerating = false;

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];

  @override
  void initState() {
    super.initState();
    _setInitialMealType();
  }

  void _setInitialMealType() {
    final hour = DateTime.now().hour;
    // Logic: 04:00 - 11:00 -> Breakfast, 11:00 - 16:00 -> Lunch, 16:00 - 22:00 -> Dinner, else -> Snack
    if (hour >= 4 && hour < 11) {
      _selectedMealType = 'Breakfast';
    } else if (hour >= 11 && hour < 16) {
      _selectedMealType = 'Lunch';
    } else if (hour >= 16 && hour < 22) {
      _selectedMealType = 'Dinner';
    } else {
      _selectedMealType = 'Snack'; 
    }
  }

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

          // Add Buttons (Row with Search & AI)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Manual Search Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openAddIngredient,
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // AI Scan Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleAIDetect,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('AI Scan'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
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

  // --- AI Detection Logic ---
  Future<void> _handleAIDetect() async {
    final aiService = Provider.of<AIService>(context, listen: false);

    // 1. Pick Source
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take a photo'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80);

      if (image == null) return;

      // 2. Show Loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Analyzing ingredients...")],
              ),
            ),
          ),
        ),
      );

      // 3. Detect
      final results = await aiService.detectProducts(image);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close loading

      // 4. Navigate to Result Page in RECIPE MODE
      final List<Map<String, dynamic>>? detectedItems = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AiDetectedProductsPage(
            image: image, 
            detectedProducts: results,
            isRecipeMode: true, // IMPORTANT: Set mode to true
          ),
        ),
      );

      // 5. Add returned items to ingredients list
      if (detectedItems != null && detectedItems.isNotEmpty) {
        setState(() {
          for (var item in detectedItems) {
            final product = item['product'] as ProductModel;
            final amount = item['amount'] as double;

            _ingredients.add(MealProductModel.fromProductWithAmount(
              productId: product.id ?? -1,
              productUuid: product.uuid,
              name: product.name,
              manufacturer: product.manufacturer,
              baseKcal: product.kcal,
              baseCarbs: product.carbs,
              baseProtein: product.protein,
              baseFat: product.fat,
              unitId: 1, 
              unitShort: 'g',
              conversionFactor: 1.0,
              amount: amount,
              consumedAt: DateTime.now(),
            ));
          }
        });
      }

    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop(); // Ensure dialog closes
      AppLogger.error("AI Detect Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing image: $e'), backgroundColor: Colors.red),
      );
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