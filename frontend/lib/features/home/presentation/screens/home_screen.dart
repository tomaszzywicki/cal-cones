import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/core/mixins/day_refresh_mixin.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/goal/data/daily_target_model.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/goal/presentation/screens/goal_setup.dart';
import 'package:frontend/features/goal/services/daily_target_service.dart';
import 'package:frontend/features/goal/services/goal_service.dart';
import 'package:frontend/features/home/presentation/widgets/day_macro_card.dart';
import 'package:frontend/features/home/presentation/widgets/warning_card.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/recipe/presentation/screens/create_recipe_screen.dart';
import 'package:frontend/features/user/presentation/screens/onboarding.dart';
import 'package:frontend/features/weight_log/presentation/screens/weight_log_main_screen.dart';
import 'package:frontend/features/weight_log/presentation/widgets/add_weight_entry_bottom_sheet.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:frontend/main_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState(); // Public State class
}

// Removed underscore to make it public for GlobalKey
class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, DayRefreshMixin {
  List<MealProductModel> _todayProducts = [];
  DailyTargetModel? _todayTargets;
  bool _isLoading = true;

  bool _hasOnboardingCompleted = true;
  bool _hasActiveGoal = true;
  bool _hasWeightData = true;
  bool _isWeightOutdated = false;

  @override
  void initState() {
    super.initState();
    loadTodayMacros();
  }

  @override
  void onDayChanged() {
    loadTodayMacros();
  }

  Future<void> loadTodayMacros() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final mealService = Provider.of<MealService>(context, listen: false);
      final dailyTargetService = context.read<DailyTargetService>();
      final goalService = context.read<GoalService>();
      final weightLogService = context.read<WeightLogService>();
      final currentUserService = context.read<CurrentUserService>();

      final today = DateTime.now();
      final userId = currentUserService.currentUser!.id;

      if (userId != null) {
        _hasOnboardingCompleted = currentUserService.currentUser!.setupCompleted;
        _hasActiveGoal = await goalService.hasActiveGoal(userId);
        _hasWeightData = await weightLogService.hasWeightData();
        _isWeightOutdated = await weightLogService.isLatestEntryOutdated();
      }

      await dailyTargetService.refreshTargetForToday();

      // Fetches from LOCAL DATABASE
      final products = await mealService.getMealProductsForDate(today);
      final targets = await dailyTargetService.getDailyTargetForDate(today);
      AppLogger.info(
        '[HomeScreen] Loaded today\'s macros: '
        'Products count=${products.length}, '
        'Targets=${targets != null ? 'calories=${targets.calories}, carbsG=${targets.carbsG}, proteinG=${targets.proteinG}, fatG=${targets.fatG}' : 'null'}',
      );

      if (!mounted) return;
      setState(() {
        _todayProducts = products;
        _todayTargets = targets;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Suppress error snackbars during rapid tab switching
      debugPrint('Error loading macros: $e');
    }
  }

  double get _consumedKcal => _todayProducts.fold(0, (sum, p) => sum + p.kcal);
  double get _consumedCarbs => _todayProducts.fold(0, (sum, p) => sum + p.carbs);
  double get _consumedProtein => _todayProducts.fold(0, (sum, p) => sum + p.protein);
  double get _consumedFat => _todayProducts.fold(0, (sum, p) => sum + p.fat);
  double get _targetKcal => _todayTargets?.calories.toDouble() ?? 2000;
  double get _targetCarbs => _todayTargets?.carbsG.toDouble() ?? 260;
  double get _targetProtein => _todayTargets?.proteinG.toDouble() ?? 120;
  double get _targetFat => _todayTargets?.fatG.toDouble() ?? 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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

                    if (!_hasOnboardingCompleted)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: WarningCard(
                          title: 'Complete Your Onboarding',
                          subtitle: 'Finish setting up your profile to get personalized target calculations.',
                          icon: Icons.info_outline,
                          color: Colors.orange,
                          buttonText: 'Complete Now',
                          buttonAction: () {
                            Navigator.of(
                              context,
                            ).push(MaterialPageRoute(builder: (context) => const Onboarding()));
                          },
                          buttonUnder: true,
                        ),
                      ),

                    if (!_hasWeightData && _hasOnboardingCompleted)
                      WarningCard(
                        title: 'Missing Weight Data',
                        subtitle: 'Log your weight to get accurate calorie targets.',
                        icon: Icons.monitor_weight_outlined,
                        color: Colors.red,
                        buttonText: 'Log Weight',
                        buttonAction: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddWeightEntryBottomSheet(),
                          ).then((_) => loadTodayMacros());
                        },
                      ),

                    if (_isWeightOutdated && _hasWeightData && _hasOnboardingCompleted)
                      WarningCard(
                        title: 'Outdated weight information',
                        subtitle:
                            'Your latest weight entry is older than ${WeightLogService.OUTDATED_THRESHOLD_DAYS} days. Please update it for accurate target calculations.',
                        icon: Icons.warning_amber_rounded,
                        color: Colors.lightBlue,
                        buttonText: 'Update Weight',
                        buttonAction: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddWeightEntryBottomSheet(),
                          ).then((_) => loadTodayMacros());
                        },
                        onAction: () {
                          Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (context) => WeightLogMainScreen()));
                        },
                      ),

                    if (!_hasActiveGoal && _hasOnboardingCompleted)
                      WarningCard(
                        title: 'You have not set a goal',
                        subtitle: 'Current calorie targets are calculated to help maintain your weight.',
                        icon: Icons.warning_amber_rounded,
                        color: Colors.orange,
                        buttonText: 'Set Goal',
                        buttonAction: () async {
                          final weightLogService = context.read<WeightLogService>();

                          final double currentWeight = weightLogService.latestEntry?.weight ?? 70.0;
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GoalSetupScreen(
                                currentWeight: currentWeight,
                                isReplacingExistingGoal: false,
                              ),
                            ),
                          );
                          if (result == true) {
                            loadTodayMacros();
                          }
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => const GoalSetup()),
                          // ).then((_) => loadTodayMacros());
                        },
                      ),

                    // const SizedBox(height: 16),

                    // Quick Stats
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
                              onTap: () {
                                context.findAncestorStateOfType<MainScreenState>()?.navigateToMealLogDate(
                                  DateTime.now().toUtc(),
                                );
                              },
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

                    // Meal Recommender Advertisement Card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.indigo.shade400, Colors.indigo.shade800],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Need inspiration?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Discover new recipes based on ingredients you have!',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const CreateRecipeScreen()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.indigo.shade800,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    icon: const Icon(Icons.auto_awesome, size: 18),
                                    label: const Text('Try Meal Gen'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.restaurant_menu_rounded, color: Colors.white24, size: 80),
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

  Widget _buildStatRow(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
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
          ),
        ),
      ),
    );
  }
}
