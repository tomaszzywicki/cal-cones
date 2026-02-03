import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/meal/data/meal_product_model.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/presentation/screens/product_details_page.dart';
import 'package:frontend/features/product/services/product_service.dart';
import 'package:frontend/features/product/presentation/tabs/search_tab.dart';
import 'package:frontend/features/product/presentation/tabs/custom_products_tab.dart';
import '../tabs/barcode_scanner_tab.dart';
import 'package:provider/provider.dart';

class ProductSearchPage extends StatefulWidget {
  final DateTime consumedAt;
  final ProductPageMode mode;
  final int initialTabIndex;

  const ProductSearchPage({
    super.key,
    required this.consumedAt,
    this.mode = ProductPageMode.add,
    this.initialTabIndex = 0,
  });

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> with SingleTickerProviderStateMixin {
  late ProductService _productService;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _productService = Provider.of<ProductService>(context, listen: false);
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        title: const Text('Add Product'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'MyProducts'),
            Tab(icon: Icon(Icons.qr_code_scanner)),
          ],
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: TabBarView(
        controller: _tabController,
        children: [
          SearchTab(productService: _productService, onProductSelected: _handleProductSelected),
          CustomProductsTab(
            onProductSelected: _handleProductSelected,
            onProductPressed: _showCustomProductDeleteDialog,
          ),
          BarcodeScannerTab(consumedAt: widget.consumedAt, mode: widget.mode),
        ],
      ),
    );
  }

  void _handleProductSelected(ProductModel product) async {
    AppLogger.info('Product selected: ${product.name}, date: ${widget.consumedAt}');
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailsPage(product: product, mode: widget.mode, consumedAt: widget.consumedAt),
      ),
    );

    if (result != null && result['success'] == true) {
      Navigator.pop(context, result);
    }
  }

  void _handleCustomProductDelete(ProductModel customProduct) async {
    final productService = Provider.of<ProductService>(context, listen: false);
    try {
      await productService.deleteCustomProduct(customProduct);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error when deleting custom product')));
      }
    }
  }

  void _showCustomProductDeleteDialog(ProductModel customProduct) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: const SingleChildScrollView(
            child: ListBody(children: [Text('Do you want to delete this product from log?')]),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                _handleCustomProductDelete(customProduct);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
