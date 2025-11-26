import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_entity.dart';
import 'package:frontend/features/meal_log/presentation/widgets/date_widget.dart';
import 'package:frontend/features/meal_log/presentation/widgets/macro_line.dart';
import 'package:frontend/features/meal_log/presentation/widgets/meal_card.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  DateTime selectedDate = DateTime.now().toUtc();
  String _dateString = "Today";
  bool _isLoading = false;

  List<MealEntity> meals = [
    MealEntity(userId: 1, name: 'Breakfast', totalKcal: 300),
    MealEntity(userId: 1, name: 'Lunch', totalKcal: 600),
  ]; // for now mocked

  void _goToPreviousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
      _updateDateString();
    });
  }

  void _goToNextDay() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
      _updateDateString();
    });
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: _goToPreviousDay),
                DateWidget(text: _dateString),
                IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: _goToNextDay),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: MacroLine(name: 'Kcal', color: Colors.blue, value: 1200, endValue: 2000),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: MacroLine(name: 'Carbs', color: Colors.green, value: 100, endValue: 150),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: MacroLine(name: 'Protein', color: Colors.red, value: 70, endValue: 120),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: MacroLine(name: 'Fat', color: Colors.yellow, value: 20, endValue: 80),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) => MealCard(meal: meals[index], onTap: () {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
