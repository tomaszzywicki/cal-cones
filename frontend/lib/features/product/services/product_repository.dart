import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/features/product/data/product_model.dart';

class ProductRepository {
  LocalDatabaseService _databaseService;

  ProductRepository(this._databaseService);

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final db = await _databaseService.database;
      List<Map<String, dynamic>> result = await db.query('products');
      return result.map((productMap) => ProductModel.fromMap(productMap)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<List<ProductModel>> getCustomProducts(int userId) async {
    try {
      final db = await _databaseService.database;
      List<Map<String, dynamic>> result = await db.query(
        'products',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      return result.map((productMap) => ProductModel.fromMap(productMap)).toList();
    } catch (e) {
      throw Exception('Failed to load custom products: $e');
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    query = query.toLowerCase();
    try {
      final db = await _databaseService.database;
      List<Map<String, dynamic>> result = await db.query(
        'products',
        where: 'lower(name) LIKE ?',
        whereArgs: ['%$query%'],
      );

      return result.map((productMap) => ProductModel.fromMap(productMap)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}
