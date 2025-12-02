import 'package:flutter/material.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/services/product_service.dart';
import 'package:frontend/features/product/presentation/widgets/product_list_tile.dart';
import 'package:provider/provider.dart';

class CustomProductsTab extends StatefulWidget {
  final Function(ProductModel) onProductSelected;

  const CustomProductsTab({super.key, required this.onProductSelected});

  @override
  State<CustomProductsTab> createState() => _CustomProductsTabState();
}

class _CustomProductsTabState extends State<CustomProductsTab> {
  List<ProductModel> _customProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomProducts();
  }

  Future<void> _loadCustomProducts() async {
    setState(() => _isLoading = true);

    try {
      final productService = Provider.of<ProductService>(context, listen: false);
      final products = await productService.loadCustomProducts();

      if (mounted) {
        setState(() {
          _customProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading custom products: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_customProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No custom products yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to create custom product
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Product'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCustomProducts,
      child: ListView.builder(
        itemCount: _customProducts.length,
        itemBuilder: (context, index) {
          final product = _customProducts[index];
          return ProductListTile(
            product: product,
            onTap: () => widget.onProductSelected(product),
            trailing: IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                // TODO: Navigate to edit product
              },
            ),
          );
        },
      ),
    );
  }
}
