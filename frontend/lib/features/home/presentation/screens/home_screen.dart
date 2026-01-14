import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/goal/data/daily_target_model.dart';
import 'package:frontend/features/goal/services/daily_target_service.dart';
import 'package:frontend/features/home/presentation/widgets/day_macro_card.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState(); // Public State class
}

// Removed underscore to make it public for GlobalKey
class HomeScreenState extends State<HomeScreen> {
  List<MealProductModel> _todayProducts = [];
  DailyTargetModel? _todayTargets;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTodayMacros();
  }

  Future<void> loadTodayMacros() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final mealService = Provider.of<MealService>(context, listen: false);
      final dailyTargetService = context.read<DailyTargetService>();
      final today = DateTime.now();
      await dailyTargetService.refreshTargetForToday();

      // Fetches from LOCAL DATABASE
      final products = await mealService.getMealProductsForDate(today);
      final targets = await dailyTargetService.getDailyTargetForDate(today);

      setState(() {
        _todayProducts = products;
        _todayTargets = targets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Suppress error snackbars during rapid tab switching
      debugPrint('Error loading macros: $e');
    }
  }

  double get _consumedKcal => _todayProducts.fold(0, (sum, p) => sum + p.kcal);
  double get _consumedCarbs => _todayProducts.fold(0, (sum, p) => sum + p.carbs);
  double get _consumedProtein => _todayProducts.fold(0, (sum, p) => sum + p.protein);
  double get _consumedFat => _todayProducts.fold(0, (sum, p) => sum + p.fat);
  double get _targetKcal => _todayTargets?.calories.toDouble() ?? 0;
  double get _targetCarbs => _todayTargets != null ? (_todayTargets!.carbsG.toDouble()) : 0;
  double get _targetProtein => _todayTargets != null ? (_todayTargets!.proteinG.toDouble()) : 0;
  double get _targetFat => _todayTargets != null ? (_todayTargets!.fatG.toDouble()) : 0;

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
              onRefresh: loadTodayMacros,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Macro Card
                    DayMacroCard(
                      consumedKcal: _consumedKcal,
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
                              'Total Products',
                              _todayProducts.length.toString(),
                              Icons.restaurant_menu,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'Calories Left',
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
