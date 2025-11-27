import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/meal/presentation/screens/meal_page.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/meal_log/presentation/widgets/date_widget.dart';
import 'package:frontend/features/meal_log/presentation/widgets/macro_line.dart';
import 'package:frontend/features/meal_log/presentation/widgets/meal_card.dart';
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
  List<MealModel> _meals = [];

  @override
  void initState() {
    super.initState();
    _mealService = Provider.of<MealService>(context, listen: false);
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);

    try {
      final meals = await _mealService.loadMealsByDate(selectedDate);
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading meals: $e')));
      }
    }
  }

  void _goToPreviousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
      _updateDateString();
    });
    _loadMeals();
  }

  void _goToNextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
      _updateDateString();
    });
    _loadMeals();
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

  int _getTotalKcal() {
    return _meals.fold(0, (sum, meal) => sum + (meal.totalKcal ?? 0));
  }

  double _getTotalCarbs() {
    return _meals.fold(0.0, (sum, meal) => sum + (meal.totalCarbs ?? 0.0));
  }

  double _getTotalProtein() {
    return _meals.fold(0.0, (sum, meal) => sum + (meal.totalProtein ?? 0.0));
  }

  double _getTotalFat() {
    return _meals.fold(0.0, (sum, meal) => sum + (meal.totalFat ?? 0.0));
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
                    value: _getTotalKcal().toDouble(),
                    endValue: 2000, // TODO: Get from user goals
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MacroLine(
                    name: 'Carbs',
                    color: Colors.green,
                    value: _getTotalCarbs(),
                    endValue: 150,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MacroLine(
                    name: 'Protein',
                    color: Colors.red,
                    value: _getTotalProtein(),
                    endValue: 120,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MacroLine(name: 'Fat', color: Colors.yellow, value: _getTotalFat(), endValue: 80),
                ),
              ],
            ),

            // Meals list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _meals.isEmpty
                  ? const Center(
                      child: Text('No meals for this day', style: TextStyle(color: Colors.grey)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMeals,
                      child: ListView.builder(
                        itemCount: _meals.length,
                        itemBuilder: (context, index) => MealCard(
                          meal: _meals[index],
                          onTap: () async {
                            await Navigator.of(
                              context,
                            ).push(MaterialPageRoute(builder: (_) => MealPage(meal: _meals[index])));
                            _loadMeals();
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
