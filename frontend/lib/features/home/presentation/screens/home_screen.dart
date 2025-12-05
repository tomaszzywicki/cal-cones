import 'package:flutter/material.dart';
import 'package:frontend/features/home/presentation/widgets/day_macro_card.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MealProductModel> _todayProducts = [];
  bool _isLoading = true;

  // Targety na razie hardcoded
  final double _targetKcal = 2500;
  final double _targetCarbs = 200;
  final double _targetProtein = 160;
  final double _targetFat = 90;

  @override
  void initState() {
    super.initState();
    _loadTodayMacros();
  }

  Future<void> _loadTodayMacros() async {
    setState(() => _isLoading = true);

    try {
      final mealService = Provider.of<MealService>(context, listen: false);
      final today = DateTime.now();

      final products = await mealService.getMealProductsForDate(today);

      setState(() {
        _todayProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading macros: $e'), backgroundColor: Colors.red));
      }
    }
  }

  double get _consumedKcal {
    return _todayProducts.fold(0, (sum, product) => sum + product.kcal);
  }

  double get _consumedCarbs {
    return _todayProducts.fold(0, (sum, product) => sum + product.carbs);
  }

  double get _consumedProtein {
    return _todayProducts.fold(0, (sum, product) => sum + product.protein);
  }

  double get _consumedFat {
    return _todayProducts.fold(0, (sum, product) => sum + product.fat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Today',
          style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTodayMacros,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Macro Card
                    DayMacroCard(
                      consumedKcal: _consumedKcal.toDouble(),
                      consumedCarbs: _consumedCarbs,
                      consumedProtein: _consumedProtein,
                      consumedFat: _consumedFat,
                      targetKcal: _targetKcal,
                      targetCarbs: _targetCarbs,
                      targetProtein: _targetProtein,
                      targetFat: _targetFat,
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Stats',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildStatRow(
                              'Total Products Added',
                              _todayProducts.length.toString(),
                              Icons.restaurant_menu,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'Calories Remaining',
                              '${(_targetKcal - _consumedKcal).round()}',
                              Icons.local_fire_department,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }
}
