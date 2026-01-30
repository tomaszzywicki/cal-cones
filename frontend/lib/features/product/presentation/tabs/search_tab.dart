import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:frontend/features/product/services/product_service.dart';
import 'package:frontend/features/product/presentation/widgets/product_list_tile.dart';
import 'package:frontend/features/product/presentation/widgets/empty_search_state.dart';

class SearchTab extends StatefulWidget {
  final ProductService productService;
  final Function(ProductModel) onProductSelected;

  const SearchTab({super.key, required this.productService, required this.onProductSelected});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  // load all products initially, maybe TODO to change logic later
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
        _showError('Error loading products: $e');
      }
    }
  }

  // Search products based on query
  Future<void> _searchProducts(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      final products = query.isEmpty
          ? await widget.productService
                .loadProducts() // to potem może też do zmiany
          : await widget.productService.searchProducts(query);

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error searching products: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                        _debounceTimer?.cancel();
                        _searchProducts('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) {
              // Debounce - 400ms
              _debounceTimer?.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 400), () {
                _searchProducts(value);
              });
            },
          ),
        ),

        // Results
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
              ? EmptySearchState(searchQuery: _searchQuery)
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ProductListTile(product: product, onTap: () => widget.onProductSelected(product));
                    // tu jakiś divider bym dał
                  },
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
