import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_entity.dart';
import 'package:frontend/features/meal_log/presentation/widgets/date_widget.dart';

class MealLogScreen extends StatelessWidget {
  const MealLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<MealEntity> meals = [];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(children: [DateWidget(text: 'Today')]),
            Row(children: []),

            // tutaj jakiś scroll view z expanded z MealCard'ami
            Expanded(child: ListView.builder(itemBuilder: (context, index) => MealCard())),
          ],
        ),
      ),
    );
  }
}
