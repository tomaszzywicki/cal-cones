import 'package:frontend/features/product/data/product_model.dart';

class AIResponse {
  ProductModel product;
  double probability;

  AIResponse({required this.product, required this.probability});

  factory AIResponse.fromMap(Map<String, dynamic> map) {
    return AIResponse(
      product: ProductModel.fromJson(map['product']),
      probability: (map['probability'] as num).toDouble(),
    );
  }
}
