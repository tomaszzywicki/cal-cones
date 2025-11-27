import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/presentation/screens/meal_page.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/presentation/screens/product_details_page.dart';
import 'package:frontend/features/product/presentation/screens/product_search_page.dart';
import 'package:provider/provider.dart';

class ShowMenuBottomSheet extends StatelessWidget {
  const ShowMenuBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) => const ShowMenuBottomSheet());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _OptionCard(
                  icon: Icons.search,
                  title: 'Search',
                  color: Colors.blue,
                  onTap: () => _handleSearchProduct(context),
                ),
                _OptionCard(
                  icon: Icons.camera_alt,
                  title: 'AI Detect',
                  color: Colors.green,
                  onTap: () => _handleAIDetect(context),
                ),
                _OptionCard(
                  icon: Icons.add,
                  title: 'Add Meal',
                  color: Colors.orange,
                  onTap: () => _handleAddMeal(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _handleSearchProduct(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    navigator.pop(); // Zamknij bottom sheet

    // Krok 1: Wybierz produkt
    final product = await navigator.push<ProductModel?>(
      MaterialPageRoute(builder: (context) => const ProductSearchPage()),
    );

    if (product == null) return;

    // Krok 2: Product details z wyborem ilości
    final result = await navigator.push<Map<String, dynamic>?>(
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(product: product, mode: ProductPageMode.addToMeal),
      ),
    );

    if (result == null) return;

    final selectedProduct = result['product'] as ProductModel;
    final amount = result['amount'] as double;
    final unit = result['unit'] as String;

    // ✅ Krok 3: Stwórz PENDING meal (bez zapisywania do DB)
    final pendingMeal = MealModel(name: 'New Meal', consumedAt: DateTime.now());

    // ✅ Stwórz PENDING meal product (też bez zapisywania)
    final pendingMealProduct = MealProductModel(
      productId: selectedProduct.id!,
      name: selectedProduct.name,
      manufacturer: selectedProduct.manufacturer,
      kcal: selectedProduct.kcal,
      carbs: selectedProduct.carbs,
      protein: selectedProduct.protein,
      fat: selectedProduct.fat,
      unitId: 1,
      unitShort: unit,
      conversionFactor: 1.0,
      amount: amount,
      createdAt: DateTime.now(),
      lastModifiedAt: DateTime.now(),
    );

    // ✅ Krok 4: Otwórz MealPage z pending data
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => MealPage(
          meal: pendingMeal,
          initialProducts: [pendingMealProduct], // ✅ Przekaż pending products
        ),
      ),
    );
  }

  static Future<void> _handleAIDetect(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    navigator.pop();
    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('AI Detection coming soon!')));
  }

  static Future<void> _handleAddMeal(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop();

    final newMeal = MealModel(name: 'New Meal', consumedAt: DateTime.now());
    await navigator.push(MaterialPageRoute(builder: (context) => MealPage(meal: newMeal)));
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
