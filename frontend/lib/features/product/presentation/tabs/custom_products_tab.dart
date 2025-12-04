import 'package:flutter/material.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/presentation/screens/add_custom_product_page.dart';
import 'package:frontend/features/product/presentation/widgets/product_list_tile.dart';
import 'package:frontend/features/product/services/product_service.dart';
import 'package:provider/provider.dart';

class CustomProductsTab extends StatefulWidget {
  final Function(ProductModel) onProductSelected;
  final Function(ProductModel) onProductPressed;

  const CustomProductsTab({super.key, required this.onProductSelected, required this.onProductPressed});

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

      setState(() {
        _customProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No custom products yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first product',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCustomProducts,
              child: ListView.builder(
                itemCount: _customProducts.length,
                itemBuilder: (context, index) {
                  final product = _customProducts[index];
                  return ProductListTile(
                    product: product,
                    onTap: () {
                      widget.onProductSelected(_customProducts[index]);
                    },
                    onPressed: () async {
                      await widget.onProductPressed(_customProducts[index]);
                      await _loadCustomProducts();
                    },
                  );
                },
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddCustomProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleAddCustomProduct() async {
    final result = await Navigator.push<ProductModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddCustomProductPage()),
    );

    if (result != null) {
      _loadCustomProducts();
    }
  }
}
