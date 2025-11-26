import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_product_entity.dart';

class MealProductPage extends StatefulWidget {
  final MealProductEntity mealProduct;
  const MealProductPage({super.key, required this.mealProduct});

  @override
  State<MealProductPage> createState() => _MealProductPageState();
}

class _MealProductPageState extends State<MealProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 36.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => Navigator.of(context).pop()),
                Text(widget.mealProduct.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
