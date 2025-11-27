import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/presentation/screens/meal_product_page.dart';
import 'package:frontend/features/meal/presentation/widgets/meal_product_card.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:provider/provider.dart';

class MealPage extends StatefulWidget {
  final MealModel meal;
  final List<MealProductModel>? initialProducts;

  const MealPage({super.key, required this.meal, this.initialProducts});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  late MealService _mealService;
  late MealModel _meal;
  List<MealProductModel> _mealProducts = [];
  bool _isLoading = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _mealService = Provider.of<MealService>(context, listen: false);
    _meal = widget.meal;
    _isSaved = _meal.id != null;

    if (widget.initialProducts != null && widget.initialProducts!.isNotEmpty) {
      _mealProducts = widget.initialProducts!;
      setState(() => _isLoading = false);
    } else {
      _loadMealProducts();
    }
  }

  Future<void> _loadMealProducts() async {
    if (_meal.id == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final products = await _mealService.loadMealProducts(_meal.id!);
      setState(() {
        _mealProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
      }
    }
  }

  Future<void> _saveMeal() async {
    if (_isSaved) return;

    try {
      final mealToSave = _meal.copyWith(
        totalKcal: _calculateTotalKcal(),
        totalCarbs: _calculateTotalCarbs().toDouble(),
        totalProtein: _calculateTotalProtein().toDouble(),
        totalFat: _calculateTotalFat().toDouble(),
      );

      final mealId = await _mealService.addMeal(mealToSave);

      for (var product in _mealProducts) {
        final productToSave = product.copyWith(mealId: mealId);
        await _mealService.addProductToMeal(productToSave, mealId);
      }

      setState(() {
        _meal = mealToSave.copyWith(id: mealId);
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Meal saved successfully!'), backgroundColor: Colors.green),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error saving meal: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // ✅ Delete meal
  Future<void> _deleteMeal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal?'),
        content: const Text('Are you sure you want to delete this meal? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (_meal.id != null) {
        // Zapisany meal - usuń z DB
        await _mealService.deleteMeal(_meal.id!);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('✅ Meal deleted'), backgroundColor: Colors.green));
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        // Pending meal - po prostu zamknij stronę
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error deleting meal: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // ✅ Show menu
  void _showMealMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Meal Name'),
              onTap: () {
                Navigator.pop(context);
                _showEditNameDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Meal', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteMeal();
              },
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: _meal.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Meal Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Meal Name', border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != _meal.name) {
      setState(() {
        _meal = _meal.copyWith(name: newName);
      });

      // Aktualizujemy jeśli meal jest już zapisany
      if (_meal.id != null && _isSaved) {
        try {
          await _mealService.updateMeal(_meal);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated')));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
          }
        }
      } else {
        // jeśli nie zapisany to akutalizujemy jego pole
      }
    }

    controller.dispose();
  }

  Future<void> _refreshProducts() async {
    if (_meal.id == null) return;
    setState(() => _isLoading = true);
    await _loadMealProducts();
  }

  void _editAmount(int index) {
    // TODO implement editing product amount
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 36.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    if (!_isSaved && _mealProducts.isNotEmpty) {
                      _showUnsavedDialog();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                Text(
                  _meal.name ?? 'New Meal',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: _showMealMenu),
              ],
            ),
            const SizedBox(height: 20),

            // Macros summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _macroColumn('Kcal', _calculateTotalKcal()),
                _macroColumn('Carbs', _calculateTotalCarbs()),
                _macroColumn('Protein', _calculateTotalProtein()),
                _macroColumn('Fat', _calculateTotalFat()),
              ],
            ),
            const SizedBox(height: 20),

            // Products list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _mealProducts.isEmpty
                  ? const Center(child: Text('No products yet'))
                  : ListView.builder(
                      itemCount: _mealProducts.length,
                      itemBuilder: (context, index) {
                        final product = _mealProducts[index];
                        return MealProductCard(
                          mealProduct: product,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    MealProductPage(mealProduct: product, mode: MealProductPageMode.edit),
                              ),
                            );
                            _refreshProducts();
                          },
                          onEditAmount: () => _editAmount(index),
                        );
                      },
                    ),
            ),

            // Confirm button
            if (!_isSaved && _mealProducts.isNotEmpty)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Confirm & Save Meal',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUnsavedDialog() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (shouldLeave == true && mounted) {
      Navigator.pop(context);
    }
  }

  int _calculateTotalKcal() {
    return _mealProducts.fold(0, (sum, p) => sum + (p.kcal * p.amount / 100).toInt());
  }

  int _calculateTotalCarbs() {
    return _mealProducts.fold(0, (sum, p) => sum + (p.carbs * p.amount / 100).toInt());
  }

  int _calculateTotalProtein() {
    return _mealProducts.fold(0, (sum, p) => sum + (p.protein * p.amount / 100).toInt());
  }

  int _calculateTotalFat() {
    return _mealProducts.fold(0, (sum, p) => sum + (p.fat * p.amount / 100).toInt());
  }

  Widget _macroColumn(String name, int value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value.toString()),
      ],
    );
  }
}
