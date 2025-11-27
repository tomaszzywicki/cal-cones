import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/features/product/data/product_model.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;
  final ProductPageMode mode;

  const ProductDetailsPage({super.key, required this.product, required this.mode});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  double _amount = 100.0;
  String _selectedUnit = 'g';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product info
                  Text('Manufacturer: ${widget.product.manufacturer ?? 'N/A'}'),
                  SizedBox(height: 16),

                  // Macros
                  _buildMacroRow('Calories', widget.product.kcal),
                  _buildMacroRow('Carbs', widget.product.carbs),
                  _buildMacroRow('Protein', widget.product.protein),
                  _buildMacroRow('Fat', widget.product.fat),

                  // Amount selector (only in addToMeal mode)
                  if (widget.mode == ProductPageMode.addToMeal) ...[
                    SizedBox(height: 24),
                    Text('Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: 'Amount'),
                            onChanged: (value) {
                              setState(() {
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
                ],
              ),
            ),
          ),

          // Bottom button (only in addToMeal mode)
          if (widget.mode == ProductPageMode.addToMeal)
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _handleConfirm, child: Text('Add to Meal')),
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
    Navigator.pop(context, {'product': widget.product, 'amount': _amount, 'unit': _selectedUnit});
  }
}
