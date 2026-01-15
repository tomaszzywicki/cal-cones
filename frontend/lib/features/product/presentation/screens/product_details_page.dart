import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/main_screen.dart';
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;
  final DateTime consumedAt;
  final ProductPageMode mode;
  final MealProductModel? mealProductToEdit;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.consumedAt,
    required this.mode,
    this.mealProductToEdit,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  double _amount = 100.0;
  String _selectedUnit = 'g';
  bool _isLoading = false;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    // Pre-fill amount if in Edit mode
    if (widget.mode == ProductPageMode.edit && widget.mealProductToEdit != null) {
      _amount = widget.mealProductToEdit!.amount;
    } else {
      _amount = widget.product.averagePortion ?? 100.0;
      if (_amount <= 0) _amount = 100.0;
    }
    _amountController = TextEditingController(text: _amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Dynamic calculations based on input amount
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
    // Check if we should show the Save/Add button
    final bool canEdit =
        widget.mode == ProductPageMode.add ||
        widget.mode == ProductPageMode.edit ||
        widget.mode == ProductPageMode.addToRecipe;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.mode == ProductPageMode.edit ? "Edit Product" : "Add Product",
            style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          actions: [
            if (widget.mode == ProductPageMode.edit)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: _showDeleteConfirmation,
                tooltip: 'Delete Entry',
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    if (widget.product.name != null) ...[
                      Text(
                        widget.product.name!,
                        style: TextStyle(fontSize: 40, color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Kcal
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FittedBox(
                                  child: Text(
                                    '$_calculatedKcal',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      letterSpacing: -1,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Calories',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Macros
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildMacroColumn(
                                  'Carbs',
                                  _calculatedCarbs,
                                  _carbsPercent,
                                  const Color(0xFF388E3C),
                                ),
                                SizedBox(width: 5),
                                _buildMacroColumn(
                                  'Protein',
                                  _calculatedProtein,
                                  _proteinPercent,
                                  const Color(0xFFD32F2F),
                                ),
                                SizedBox(width: 5),
                                _buildMacroColumn(
                                  'Fat',
                                  _calculatedFat,
                                  _fatPercent,
                                  const Color(0xFFF57C00),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Show input fields only for Add/Edit modes
                    if (canEdit) ...[
                      const SizedBox(height: 32),

                      // Amount label
                      Text(
                        'Amount',
                        style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      // Amount input
                      Center(
                        child: Container(
                          width: 300,
                          height: 60,
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            // color: Colors.grey[50],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Decrease button
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.remove, size: 20, color: Colors.black),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      _amount = (_amount - 10).clamp(10, 999);
                                      _amountController.text = _amount.toStringAsFixed(0);
                                    });
                                  },
                                ),
                              ),

                              // Amount text field area
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: TextField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(3),
                                        ],
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            final parsed = double.tryParse(value) ?? 100.0;
                                            _amount = parsed.clamp(1, 999);
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedUnit,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Increase button
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                child: IconButton(
                                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      _amount = (_amount + 10).clamp(10, 999);
                                      _amountController.text = _amount.toStringAsFixed(0);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ===== BOTTOM BUTTON =====
            if (canEdit)
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
                          : Text(
                              widget.mode == ProductPageMode.edit ? 'Save Changes' : 'Add to log',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroColumn(String label, double value, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${percent.round()}%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, height: 1.0),
            ),
          ),
        ),
        const SizedBox(height: 8),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500, height: 1.0),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          backgroundColor: Colors.white,
          content: const Text('Are you sure you want to remove this product from your log?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteEntry();
    }
  }

  Future<void> _deleteEntry() async {
    setState(() => _isLoading = true);

    try {
      final mealService = Provider.of<MealService>(context, listen: false);

      if (widget.mealProductToEdit != null) {
        await mealService.deleteMealProduct(widget.mealProductToEdit!);
      }

      if (!mounted) return;

      // Pop the screen. The MealLogScreen will detect the return and refresh the list.
      Navigator.pop(context, {'deleted': true});
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting entry: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    try {
      // HANDLE ADD TO RECIPE MODE
      if (widget.mode == ProductPageMode.addToRecipe) {
        final product = widget.product;
        // Create a temporary MealProductModel (not saved to DB yet)
        final tempMealProduct = MealProductModel.fromProductWithAmount(
          productId: product.id ?? -99,
          productUuid: product.uuid,
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
          consumedAt: DateTime.now(),
        );

        Navigator.pop(context, {'success': true, 'mealProduct': tempMealProduct});
        return;
      }
      
      // HANDLE EDIT OR ADD TO LOG
      final mealProductService = Provider.of<MealService>(context, listen: false);

      if (widget.mode == ProductPageMode.edit && widget.mealProductToEdit != null) {
        final updatedProduct = widget.mealProductToEdit!.updateAmount(_amount);
        await mealProductService.updateMealProduct(updatedProduct);

        if (mounted) {
          Navigator.pop(context, {'success': true, 'amount': _amount});
        }
      } else {
        final product = widget.product;
        final mealProduct = MealProductModel.fromProductWithAmount(
          productId: product.id ?? -99,
          productUuid: product.uuid,
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
        await mealProductService.addMealProduct(mealProduct);

        if (!mounted) return;

        // === REDIRECT LOGIC ===
        // 1. Pop everything until we hit the MainScreen (the root)
        Navigator.of(context).popUntil((route) => route.isFirst);
        // 2. Programmatically switch to Meal Log tab and refresh
        mainScreenKey.currentState?.navigateToMealLog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
