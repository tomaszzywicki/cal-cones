import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/ai/data/ai_response.dart';
import 'package:frontend/features/ai/presentation/widgets/ai_product_card.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AiDetectedProductsPage extends StatefulWidget {
  final XFile? image;
  final List<List<AIResponse>> detectedProducts;

  const AiDetectedProductsPage({super.key, required this.image, required this.detectedProducts});

  @override
  State<AiDetectedProductsPage> createState() => _AiDetectedProductsPageState();
}

class _AiDetectedProductsPageState extends State<AiDetectedProductsPage> {
  final Map<int, _AcceptedProduct> _acceptedProducts = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Model Analysis',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // ✅ Wszystko w jednym scrollable
          Expanded(
            child: widget.detectedProducts.isEmpty
                ? _buildEmptyState()
                : CustomScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      // Header z obrazem
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Found ${widget.detectedProducts.length} items',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 24,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Image
                              Container(
                                width: double.infinity,
                                height: 220,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: FileImage(File(widget.image!.path)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),

                      // Lista produktów
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final predictions = widget.detectedProducts[index];
                            return AiProductCard(
                              key: ValueKey(index),
                              predictions: predictions,
                              onRemove: () => _onRemove(index),
                              onAccepted: (product, weight) => _onAccepted(index, product, weight),
                            );
                          }, childCount: widget.detectedProducts.length),
                        ),
                      ),

                      // Padding na dole żeby ostatni item nie był zakryty przez przycisk
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
          ),

          // Przycisk (zawsze na dole)
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  'Confirm ${_acceptedProducts.isNotEmpty ? "(${_acceptedProducts.length})" : ""}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No products detected", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  void _onRemove(int index) {
    setState(() {
      widget.detectedProducts.removeAt(index);
      _acceptedProducts.remove(index);
    });
  }

  void _onAccepted(int index, AIResponse product, double weight) {
    setState(() {
      _acceptedProducts[index] = _AcceptedProduct(product: product, weight: weight);
    });
    AppLogger.info("Product '${product.product.name}' accepted with weight: $weight g");
  }

  Future<void> _handleConfirm() async {
    if (_acceptedProducts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please accept at least one product')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final mealService = Provider.of<MealService>(context, listen: false);
      AppLogger.info('Saving ${_acceptedProducts.length} products to meal log');

      // Konwertuj na format do zapisu
      final productsToSave = _acceptedProducts.entries.map((entry) {
        final accepted = entry.value;
        return {
          'product': accepted.product.product,
          'weight': accepted.weight,
          'confidence': accepted.product.probability,
        };
      }).toList();

      await mealService.addMealProductsFromAI(productsToSave, DateTime.now());

      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Added ${_acceptedProducts.length} products to meal log'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      AppLogger.error('Failed to save meal products: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save products: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _AcceptedProduct {
  final AIResponse product;
  final double weight;
  _AcceptedProduct({required this.product, required this.weight});
}
