import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';

class MealProductPage extends StatefulWidget {
  final MealProductModel mealProduct;
  final MealProductPageMode mode;

  const MealProductPage({super.key, required this.mealProduct, required this.mode});

  @override
  State<MealProductPage> createState() => _MealProductPageState();
}

class _MealProductPageState extends State<MealProductPage> {
  double _amount = 0.0;
  String _selectedUnit = '';

  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amount = widget.mealProduct.amount;
    _selectedUnit = widget.mealProduct.unitShort;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.mealProduct.name)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product info
                  Text('Manufacturer: ${widget.mealProduct.manufacturer ?? 'N/A'}'),
                  SizedBox(height: 16),

                  // Macros
                  _buildMacroRow('Calories', widget.mealProduct.kcal),
                  _buildMacroRow('Carbs', widget.mealProduct.carbs),
                  _buildMacroRow('Protein', widget.mealProduct.protein),
                  _buildMacroRow('Fat', widget.mealProduct.fat),

                  // Amount selector (only in addToMeal mode)
                  SizedBox(height: 24),
                  Text('Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: 'Amount'),
                          onChanged: (value) {
                            setState(() {
                              print(value);
                              _amount = double.tryParse(value) ?? 100.0;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedUnit,
                        items: ['g'].map((unit) {
                          return DropdownMenuItem(value: unit, child: Text(unit));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom button (only in addToMeal mode)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _handleConfirm, child: Text('Save')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, num value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text('$value')]),
    );
  }

  void _handleConfirm() {
    // true = confirmed
    Navigator.pop(context, true);
  }
}
