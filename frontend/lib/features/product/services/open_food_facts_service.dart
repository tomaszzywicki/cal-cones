import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../data/product_model.dart';

class OpenFoodFactsService {
  
  static Future<ProductModel?> fetchProductByBarcode(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1 && data['product'] != null) {
          final productData = data['product'];
          final nutriments = productData['nutriments'] ?? {};

          // Helper to safely get double values
          double getVal(dynamic val) {
            if (val == null) return 0.0;
            if (val is int) return val.toDouble();
            if (val is double) return val;
            if (val is String) return double.tryParse(val) ?? 0.0;
            return 0.0;
          }
          
           // Helper to safely get int values
          int getIntVal(dynamic val) {
            if (val == null) return 0;
            if (val is int) return val;
            if (val is double) return val.round();
            if (val is String) return int.tryParse(val) ?? 0;
            return 0;
          }

          final now = DateTime.now();

          // Corrected ProductModel instantiation
          return ProductModel(
            uuid: const Uuid().v4(),
            userId: 0, 
            name: productData['product_name'] ?? productData['product_name_en'] ?? productData['product_name_pl'] ??  'Unknown Product',
            manufacturer: productData['brands'] ?? '',
            kcal: getIntVal(nutriments['energy-kcal_100g']),
            protein: getVal(nutriments['proteins_100g']),
            carbs: getVal(nutriments['carbohydrates_100g']),
            fat: getVal(nutriments['fat_100g']),
            createdAt: now,        
            lastModifiedAt: now,  
            isSynced: false,
          );
        }
      }
    } catch (e) {
      print('Error fetching barcode product: $e');
    }
    return null;
  }
}