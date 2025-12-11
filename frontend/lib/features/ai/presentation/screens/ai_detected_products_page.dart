import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/ai/data/ai_response.dart';
import 'package:frontend/features/ai/presentation/widgets/ai_product_card.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:image_picker/image_picker.dart';

class AiDetectedProductsPage extends StatefulWidget {
  final XFile? image;
  final List<AIResponse> detectedProducts;

  const AiDetectedProductsPage({super.key, required this.image, required this.detectedProducts});

  @override
  State<AiDetectedProductsPage> createState() => _AiDetectedProductsPageState();
}

class _AiDetectedProductsPageState extends State<AiDetectedProductsPage> {
  final Map<int, double> _acceptedProducts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Padding(
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
                    image: DecorationImage(image: FileImage(File(widget.image!.path)), fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),

          // Produkty
          Expanded(
            child: widget.detectedProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.detectedProducts.length,
                    itemBuilder: (context, index) {
                      final item = widget.detectedProducts[index];
                      return AiProductCard(
                        key: ValueKey(item.product.name),
                        item: item,
                        onRemove: () => _onRemove(index),
                        onAccepted: (weight) => _onAccepted(index, weight),
                      );
                    },
                  ),
          ),

          // Przycisk
          Container(
            padding: const EdgeInsets.all(20),
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
                onPressed: _acceptedProducts.isNotEmpty ? _handleConfirm : null,
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

  void _onAccepted(int index, double amount) {
    setState(() {
      _acceptedProducts[index] = amount;
    });
    AppLogger.info("Product at index $index accepted with weight: $amount");
  }

  Future<void> _handleConfirm() async {
    AppLogger.info('Saving ${_acceptedProducts.length} products to meal log');
    // TODO logika zapisu
    Navigator.of(context).pop();
  }
}
