import 'package:flutter/material.dart';
import 'package:frontend/features/meal/data/meal_model.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/services/product_service.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(text: 'Custom Meals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SearchTab(productService: _productService, onProductSelected: _handleProductSelected),
          _CustomProductsTab(onProductSelected: _handleProductSelected),
          _CustomMealsTab(onMealSelected: _handleMealSelected),
        ],
      ),
    );
  }

  void _handleProductSelected(ProductModel product) {
    Navigator.pop(context, product); // przekazujemy sobie produkt do tej funkcji z bottomSheet
  }

  void _handleMealSelected(MealModel meal) {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// === SEARCH TAB z live search ===
class _SearchTab extends StatefulWidget {
  final ProductService productService;
  final Function(ProductModel) onProductSelected;

  const _SearchTab({required this.productService, required this.onProductSelected});

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    setState(() => _isLoading = true);

    try {
      final products = await widget.productService.loadProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _searchProducts(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      final products = await widget.productService.searchProducts(query);
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchProducts('');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Debounce - 200ms
              Future.delayed(const Duration(milliseconds: 200), () {
                if (value == _searchController.text) {
                  _searchProducts(value);
                }
              });
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty ? 'No products found' : 'No results for "$_searchQuery"',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.1),
                        child: const Icon(Icons.apple, color: Colors.black),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        '${product.kcal} kcal  C: ${product.carbs}g  P: ${product.protein}g  F: ${product.fat}g',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => widget.onProductSelected(product),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _CustomProductsTab extends StatelessWidget {
  final Function(ProductModel) onProductSelected;

  const _CustomProductsTab({required this.onProductSelected});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Your custom products'));
  }
}

class _CustomMealsTab extends StatelessWidget {
  final Function(MealModel) onMealSelected;

  const _CustomMealsTab({required this.onMealSelected});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Your custom meals'));
  }
}
