import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;
  final DateTime consumedAt;
  final ProductPageMode mode;

  const ProductDetailsPage({super.key, required this.product, required this.consumedAt, required this.mode});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  double _amount = 100.0;
  String _selectedUnit = 'g';
  bool _isLoading = false;
  final TextEditingController _amountController = TextEditingController(text: '100');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _calculatedKcal => (widget.product.kcal * _amount / 100).round();
  double get _calculatedProtein => widget.product.protein * _amount / 100;
  double get _calculatedCarbs => widget.product.carbs * _amount / 100;
  double get _calculatedFat => widget.product.fat * _amount / 100;

  double get _proteinPercent {
    if (_calculatedKcal == 0) return 0;
    return ((_calculatedProtein * 4) / _calculatedKcal * 100).clamp(0, 100);
  }

  double get _carbsPercent {
    if (_calculatedKcal == 0) return 0;
    return ((_calculatedCarbs * 4) / _calculatedKcal * 100).clamp(0, 100);
  }

  double get _fatPercent {
    if (_calculatedKcal == 0) return 0;
    return ((_calculatedFat * 9) / _calculatedKcal * 100).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product.name,
          style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== MANUFACTURER =====
                  if (widget.product.manufacturer != null) ...[
                    Text(
                      widget.product.manufacturer!,
                      style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ===== NUTRITION SUMMARY (MacroFactor style) =====
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Kcal
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_calculatedKcal',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: -2,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Calories',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 32),

                        // Macros
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMacroColumn(
                                'Protein',
                                _calculatedProtein,
                                _proteinPercent,
                                const Color(0xFFD32F2F),
                              ),
                              _buildMacroColumn('Fat', _calculatedFat, _fatPercent, const Color(0xFFF57C00)),
                              _buildMacroColumn(
                                'Carbs',
                                _calculatedCarbs,
                                _carbsPercent,
                                const Color(0xFF388E3C),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (widget.mode == ProductPageMode.add) ...[
                    const SizedBox(height: 32),

                    // Amount label
                    Text(
                      'Amount',
                      style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Amount input
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          // Decrease button
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _amount = (_amount - 10).clamp(10, 10000);
                                _amountController.text = _amount.toStringAsFixed(0);
                              });
                            },
                          ),

                          // Amount text field
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: -1,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4), // max 9999
                              ],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '100',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  final parsed = double.tryParse(value) ?? 100.0;
                                  _amount = parsed.clamp(1, 10000);
                                });
                              },
                            ),
                          ),

                          // Unit
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Text(
                              _selectedUnit,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),

                          // Increase button
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _amount = (_amount + 10).clamp(10, 10000);
                                _amountController.text = _amount.toStringAsFixed(0);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ===== BOTTOM BUTTON =====
          if (widget.mode == ProductPageMode.add)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Add to Meal',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMacroColumn(String label, double value, double percent, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Text(
            '${percent.round()}%',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    final mealProductService = Provider.of<MealService>(context, listen: false);
    final product = widget.product;

    final mealProduct = MealProductModel.fromProductWithAmount(
      productId: product.id ?? -99,
      name: product.name,
      manufacturer: product.manufacturer,
      baseKcal: product.kcal,
      baseCarbs: product.carbs,
      baseProtein: product.protein,
      baseFat: product.fat,
      unitId: 1,
      unitShort: 'g',
      conversionFactor: 1.0,
      amount: _amount,
      consumedAt: widget.consumedAt,
    );

    try {
      await mealProductService.addMealProduct(mealProduct);

      if (!mounted) return;

      Navigator.pop(context, {
        'success': true,
        'product': product,
        'amount': _amount,
        'unit': _selectedUnit,
        'consumedAt': widget.consumedAt,
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding product: $e'), backgroundColor: Colors.red));
    }
  }
}
