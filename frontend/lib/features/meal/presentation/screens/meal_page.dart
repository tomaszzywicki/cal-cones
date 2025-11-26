import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_entity.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/presentation/screens/meal_product_page.dart';
import 'package:frontend/features/meal/presentation/widgets/meal_product_card.dart';

class MealPage extends StatefulWidget {
  final MealModel meal;
  const MealPage({super.key, required this.meal});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  // final MealService mealService = Provider.of<MealService>(context, listen: false);
  List<MealProductModel> mealProducts = [
    MealProductModel(
      mealId: 1,
      userId: 1,
      productId: 1,
      name: 'Oats',
      kcal: 150,
      carbs: 27.0,
      protein: 5.0,
      fat: 3.0,
      unitId: 1,
      unitShort: 'g',
      conversionFactor: 1.0,
      amount: 50.0,
      createdAt: DateTime.now(),
      lastModifiedAt: DateTime.now(),
    ),
    MealProductModel(
      mealId: 1,
      userId: 1,
      productId: 2,
      name: 'Banana',
      kcal: 100,
      carbs: 23.0,
      protein: 1.0,
      fat: 0.5,
      unitId: 1,
      unitShort: 'g',
      conversionFactor: 1.0,
      amount: 100.0,
      createdAt: DateTime.now(),
      lastModifiedAt: DateTime.now(),
    ),
  ]; // for now mocked

  @override
  void initState() {
    super.initState();
    // mealProducts = await mealService.loadMealProducts(widget.meal.id!)
  }

  void _editAmount(int index) {
    // TODO implement editing product amount
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 36.0),
        child: Column(
          children: [
            Row(
              // buttons at ends and title in center
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Container(
                  child: Text(
                    widget.meal.name ?? 'New Meal',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    // jakieś okienko z opcjami
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _macroColumn('Kcal', widget.meal.totalKcal ?? 0),
                _macroColumn('Carbs', widget.meal.totalCarbs != null ? widget.meal.totalCarbs!.toInt() : 0),
                _macroColumn(
                  'Protein',
                  widget.meal.totalProtein != null ? widget.meal.totalProtein!.toInt() : 0,
                ),
                _macroColumn('Fat', widget.meal.totalFat != null ? widget.meal.totalFat!.toInt() : 0),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: mealProducts.length,
                itemBuilder: (context, index) {
                  final product = mealProducts[index];
                  return MealProductCard(
                    mealProduct: product,
                    onTap: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => MealProductPage(mealProduct: product))),
                    onEditAmount: () => _editAmount(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroColumn(String name, int value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
        Text(value.toString()),
      ],
    );
  }
}
