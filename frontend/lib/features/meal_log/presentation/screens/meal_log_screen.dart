import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_entity.dart';
import 'package:frontend/features/meal_log/presentation/widgets/date_widget.dart';
import 'package:frontend/features/meal_log/presentation/widgets/meal_card.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  @override
  Widget build(BuildContext context) {
    List<MealEntity> meals = [
      MealEntity(userId: 1, name: 'Breakfast', totalKcal: 300),
      MealEntity(userId: 1, name: 'Lunch', totalKcal: 600),
    ]; // for now mocked

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(children: [DateWidget(text: 'Today')]), // tu po bokach przyciski do zmiany daty w przód i tył
            Row(children: []), // tutaj 4 razy macro line czy jakkolwiek to nazwać
            // tutaj jakiś scroll view z expanded z MealCard'ami
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => MealCard(meal: meals[index], onTap: () {}),
                itemCount: meals.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
