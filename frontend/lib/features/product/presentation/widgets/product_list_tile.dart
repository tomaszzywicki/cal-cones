import 'package:flutter/material.dart';
import 'package:frontend/features/product/data/product_model.dart';

class ProductListTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onPressed;
  final Widget? trailing;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onTap,
    this.onPressed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.manufacturer != null && product.manufacturer!.isNotEmpty)
            Text(product.manufacturer!, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(
            '${product.kcal} kcal  •  C: ${product.carbs.toStringAsFixed(1)}g  P: ${product.protein.toStringAsFixed(1)}g  F: ${product.fat.toStringAsFixed(1)}g',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      onLongPress: onPressed,
    );
  }
}
