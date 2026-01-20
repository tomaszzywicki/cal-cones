import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/core/mixins/day_refresh_mixin.dart';
import 'package:frontend/features/goal/data/daily_target_model.dart';
import 'package:frontend/features/goal/services/daily_target_service.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/presentation/screens/meal_product_page.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/meal_log/presentation/widgets/date_widget.dart';
import 'package:frontend/features/meal_log/presentation/widgets/macro_line.dart';
import 'package:frontend/features/meal_log/presentation/widgets/meal_card.dart';
import 'package:frontend/features/product/presentation/screens/product_search_page.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/presentation/screens/product_details_page.dart';
import 'package:frontend/show_menu_bottom_sheet.dart';
import 'package:provider/provider.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => MealLogScreenState();
}

// CHANGED: Removed underscore to make class public
class MealLogScreenState extends State<MealLogScreen> with WidgetsBindingObserver, DayRefreshMixin {
  late MealService _mealService;

  DateTime selectedDate = DateTime.now().toUtc();
  String _dateString = "Today";
  bool _isLoading = false;

  List<MealProductModel> _mealProducts = [];
  DailyTargetModel? _dailyTargets;

  double _totalKcal = 0;
  double _totalCarbs = 0;
  double _totalProtein = 0;
  double _totalFat = 0;

  @override
  void initState() {
    super.initState();
    _mealService = Provider.of<MealService>(context, listen: false);
    loadMealProducts();
  }

  @override
  void onDayChanged() {
    setState(() {
      _updateDateString();
    });
  }

  Future<void> loadMealProducts() async {
    setState(() => _isLoading = true);

    try {
      final dailyTargetService = context.read<DailyTargetService>();
      final mealProducts = await _mealService.getMealProductsForDate(selectedDate);
      final dailyTargets = await dailyTargetService.getDailyTargetForDate(selectedDate);
      setState(() {
        _mealProducts = mealProducts;
        _dailyTargets = dailyTargets;
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

  void _goToPreviousDay() async {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
      _updateDateString();
    });
    await loadMealProducts();
  }

  void _goToNextDay() async {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
      _updateDateString();
    });
    await loadMealProducts();
  }

  Future<void> goToDate(DateTime date) async {
    setState(() {
      selectedDate = date;
      _updateDateString();
    });
    await loadMealProducts();
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

  double get _targetKcal => _dailyTargets?.calories.toDouble() ?? 2000;
  double get _targetCarbs => _dailyTargets?.carbsG.toDouble() ?? 150;
  double get _targetProtein => _dailyTargets?.proteinG.toDouble() ?? 120;
  double get _targetFat => _dailyTargets?.fatG.toDouble() ?? 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: GestureDetector(
        // Allow touches to pass through to children (crucial for empty areas)
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity == null) return;

          // Velocity > 0 : Swipe Right (Back to previous day)
          if (details.primaryVelocity! > 0) {
            _goToPreviousDay();
          }
          // Velocity < 0 : Swipe Left (Forward to next day)
          else if (details.primaryVelocity! < 0) {
            _goToNextDay();
          }
        },
        child: Padding(
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
                      endValue: _targetKcal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MacroLine(
                      name: 'Carbs',
                      color: Colors.green,
                      value: _totalCarbs,
                      endValue: _targetCarbs,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MacroLine(
                      name: 'Protein',
                      color: Colors.red,
                      value: _totalProtein,
                      endValue: _targetProtein,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MacroLine(name: 'Fat', color: Colors.yellow, value: _totalFat, endValue: _targetFat),
                  ),
                ],
              ),

              // Products list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: loadMealProducts,
                        child: _mealProducts.isEmpty
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                      child: const Center(
                                        child: Text(
                                          'No products for this day',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: _mealProducts.length,
                                // Product Cards
                                itemBuilder: (context, index) => ProductCard(
                                  mealProduct: _mealProducts[index],
                                  onTap: () async {
                                    _handleEditProduct(_mealProducts[index]);
                                  },
                                  onLongPress: () async {
                                    _showDeleteConfirmation(_mealProducts[index]);
                                  },
                                  onEditAmount: () {
                                    _showEditDialog(_mealProducts[index]);
                                  },
                                ),
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: SizedBox(
        height: 50, 
        child: FloatingActionButton.extended(
          onPressed: () {
            _handleAddProduct();
          },
          backgroundColor: Colors.black,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text(
            "Add product for this day",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _handleAddProduct() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>?>(
      MaterialPageRoute(builder: (context) => ProductSearchPage(consumedAt: selectedDate)),
    );

    if (result != null && result['success'] == true) {
      await loadMealProducts();
    }
  }

  Future<void> _handleEditProduct(MealProductModel mealProduct) async {
    // 1. We need to calculate the "Base" (per 100g) values from the logged product
    // so that ProductDetailsPage can recalculate them dynamically.
    final double factor = (mealProduct.amount * mealProduct.conversionFactor) / 100.0;

    // Avoid division by zero
    final double safeFactor = factor <= 0 ? 1.0 : factor;

    // 2. Create a temporary ProductModel with base values
    final baseProduct = ProductModel(
      id: null,
      uuid: mealProduct.productUuid,
      userId: mealProduct.userId ?? 0,
      name: mealProduct.name,
      manufacturer: mealProduct.manufacturer,
      // Reverse calculation to get values per 100g
      kcal: (mealProduct.kcal / safeFactor).round(),
      carbs: mealProduct.carbs / safeFactor,
      protein: mealProduct.protein / safeFactor,
      fat: mealProduct.fat / safeFactor,
      createdAt: DateTime.now(),
      lastModifiedAt: DateTime.now(),
    );

    // 3. Open ProductDetailsPage in Edit Mode
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          product: baseProduct,
          consumedAt: mealProduct.createdAt,
          mode: ProductPageMode.edit,
          mealProductToEdit: mealProduct, // Pass the original entry so we can update it
        ),
      ),
    );

    // 4. Refresh the list when we return
    await loadMealProducts();
  }

  Future<void> _handleDeleteProduct(MealProductModel mealProduct) async {
    // 1. Create a backup of the item and its index
    final int backupIndex = _mealProducts.indexOf(mealProduct);
    final MealProductModel backupItem = mealProduct;

    // 2. Immediately remove from UI
    setState(() {
      _mealProducts.remove(mealProduct);
      _calculateTotals(); // Refresh calorie/macro bars immediately
    });

    try {
      // 3. Send delete request in the background (server/database)
      final mealService = Provider.of<MealService>(context, listen: false);
      await mealService.deleteMealProduct(mealProduct);
    } catch (e) {
      // 4. If an error occurs, we restore the item to the list (Rollback)
      if (mounted) {
        setState(() {
          _mealProducts.insert(backupIndex, backupItem);
          _calculateTotals();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _handleEditAmount(MealProductModel mealProduct, double amount) async {
    try {
      final mealService = Provider.of<MealService>(context, listen: false);

      final updatedProduct = mealProduct.updateAmount(amount);

      await mealService.updateMealProduct(updatedProduct);
      await loadMealProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating amount: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showDeleteConfirmation(MealProductModel mealProduct) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          backgroundColor: Colors.white,
          content: const Text('Are you sure you want to remove this product from your log?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _handleDeleteProduct(mealProduct);
    }
  }

  Future<void> _showEditDialog(MealProductModel mealProduct) async {
    final TextEditingController amountController = TextEditingController(
      text: mealProduct.amount.toStringAsFixed(0),
    );

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Amount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mealProduct.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: const OutlineInputBorder(),
                  suffixText: mealProduct.unitShort,
                  hintText: 'Enter amount',
                ),
                onSubmitted: (value) async {
                  final newAmount = double.tryParse(value);
                  if (newAmount != null && newAmount > 0) {
                    Navigator.of(context).pop();
                    await _handleEditAmount(mealProduct, newAmount);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Current: ${mealProduct.amount.toStringAsFixed(0)} ${mealProduct.unitShort}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newAmount = double.tryParse(amountController.text);
                if (newAmount != null && newAmount > 0) {
                  Navigator.of(context).pop();
                  await _handleEditAmount(mealProduct, newAmount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}