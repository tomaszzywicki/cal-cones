import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/presentation/screens/meal_product_page.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/meal_log/presentation/widgets/date_widget.dart';
import 'package:frontend/features/meal_log/presentation/widgets/macro_line.dart';
import 'package:frontend/features/meal_log/presentation/widgets/meal_card.dart';
import 'package:frontend/features/product/presentation/screens/product_details_page.dart';
import 'package:frontend/features/product/presentation/screens/product_search_page.dart';
import 'package:provider/provider.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  late MealService _mealService;

  DateTime selectedDate = DateTime.now().toUtc();
  String _dateString = "Today";
  bool _isLoading = false;

  List<MealProductModel> _mealProducts = [];

  double _totalKcal = 0;
  double _totalCarbs = 0;
  double _totalProtein = 0;
  double _totalFat = 0;

  @override
  void initState() {
    super.initState();
    _mealService = Provider.of<MealService>(context, listen: false);
    _loadMealProducts();
  }

  Future<void> _loadMealProducts() async {
    setState(() => _isLoading = true);

    try {
      final mealProducts = await _mealService.getMealProductsForDate(selectedDate);
      setState(() {
        _mealProducts = mealProducts;
        _isLoading = false;
        _calculateTotals();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
      }
    }
  }

  void _calculateTotals() {
    _totalKcal = 0;
    _totalCarbs = 0;
    _totalProtein = 0;
    _totalFat = 0;

    for (var mealProduct in _mealProducts) {
      _totalKcal += mealProduct.kcal;
      _totalCarbs += mealProduct.carbs;
      _totalProtein += mealProduct.protein;
      _totalFat += mealProduct.fat;
    }
  }

  void _goToPreviousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
      _updateDateString();
    });
    _loadMealProducts();
  }

  void _goToNextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
      _updateDateString();
    });
    _loadMealProducts();
  }

  void _updateDateString() {
    DateTime now = DateTime.now().toUtc();
    if (selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day) {
      _dateString = "Today";
    } else {
      _dateString =
          "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 36.0),
        child: Column(
          children: [
            // Date selector
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: _goToPreviousDay),
                DateWidget(text: _dateString),
                IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: _goToNextDay),
              ],
            ),
            const SizedBox(height: 10),

            // Macro summary
            Row(
              children: [
                Expanded(
                  child: MacroLine(
                    name: 'Kcal',
                    color: Colors.blue,
                    value: _totalKcal,
                    endValue: 2000, // TODO: Get from user goals
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MacroLine(name: 'Carbs', color: Colors.green, value: _totalCarbs, endValue: 150),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MacroLine(name: 'Protein', color: Colors.red, value: _totalProtein, endValue: 120),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MacroLine(name: 'Fat', color: Colors.yellow, value: _totalFat, endValue: 80),
                ),
              ],
            ),

            // Products list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _mealProducts.isEmpty
                  ? const Center(
                      child: Text('No products for this day', style: TextStyle(color: Colors.grey)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMealProducts,
                      child: ListView.builder(
                        itemCount: _mealProducts.length,
                        // Product Cards
                        itemBuilder: (context, index) => ProductCard(
                          mealProduct: _mealProducts[index],
                          onTap: () async {
                            _handleEditProduct(_mealProducts[index]);
                          },
                          onLongPress: () async {
                            _showDeleteDialog(_mealProducts[index]);
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),

      // TODO adjust style of button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _handleAddProduct();
        },
        label: const Text('Add Product for today', style: TextStyle(fontSize: 13)),
        icon: const Icon(Icons.add, size: 20),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _handleAddProduct() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>?>(
      MaterialPageRoute(builder: (context) => ProductSearchPage(consumedAt: selectedDate)),
    );

    if (result != null && result['success'] == true) {
      _loadMealProducts();
    }
  }

  Future<void> _handleEditProduct(MealProductModel mealProduct) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MealProductPage(mealProduct: mealProduct, mode: MealProductPageMode.edit),
      ),
    );
    _loadMealProducts();
  }

  Future<void> _handleDeleteProduct(MealProductModel mealProduct) async {
    final mealService = Provider.of<MealService>(context, listen: false);
    await mealService.deleteMealProduct(mealProduct);
    _loadMealProducts();
  }

  Future<void> _showDeleteDialog(MealProductModel mealProduct) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: const SingleChildScrollView(
            child: ListBody(children: [Text('Do you want to delete this product from log?')]),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                _handleDeleteProduct(mealProduct);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
