import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/services/product_service.dart';
import 'package:frontend/features/product/presentation/tabs/search_tab.dart';
import 'package:frontend/features/product/presentation/tabs/custom_products_tab.dart';
import 'package:provider/provider.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Custom Products'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SearchTab(productService: _productService, onProductSelected: _handleProductSelected),
          CustomProductsTab(onProductSelected: _handleProductSelected),
        ],
      ),
    );
  }

  void _handleProductSelected(ProductModel product) {
    // TODO: Navigate to product details or add to meal
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
