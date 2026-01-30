import 'package:frontend/features/product/data/product_model.dart';

class AIResponse {
  final ProductModel product;
  final double probability;

  AIResponse({required this.product, required this.probability});

  factory AIResponse.fromMap(Map<String, dynamic> map) {
    return AIResponse(
      product: ProductModel.fromJson(map['product'] as Map<String, dynamic>),
      probability: (map['probability'] as num).toDouble(),
    );
  }
}
