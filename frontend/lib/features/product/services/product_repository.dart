import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/product/data/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductRepository {
  LocalDatabaseService _databaseService;

  ProductRepository(this._databaseService);

  // ============= CRUD ==================== //
  Future<ProductModel> createCustomProduct(ProductModel product, int userId) async {
    product.userId = userId;
    try {
      final db = await _databaseService.database;
      final id = await db.insert('products', product.toMap());
      final uuid = Uuid().v4();
      return product.copyWith(id: id, uuid: uuid);
    } catch (e) {
      AppLogger.error('Failed to add custom product: $e');
      throw Exception('Failed to add custom product');
    }
  }

  Future<int> updateCustomProduct(ProductModel customProduct, int userId) async {
    try {
      final db = await _databaseService.database;
      customProduct = customProduct.copyWith(isSynced: false, lastModifiedAt: DateTime.now().toUtc());
      return await db.update(
        'products',
        customProduct.toMap(),
        where: 'id = ? AND user_id = ?',
        whereArgs: [customProduct.id, userId],
      );
    } catch (e) {
      AppLogger.error("Error updating product: $e");
      throw Exception('Error updating product: $e');
    }
  }

  Future<int> deleteCustomProduct(ProductModel customProduct, int userId) async {
    try {
      final db = await _databaseService.database;
      return await db.delete(
        'products',
        where: 'id = ? AND user_id = ?',
        whereArgs: [customProduct.id, userId],
      );
    } catch (e) {
      AppLogger.error("Error deleting product: $e");
      throw Exception('Error deleting product: $e');
    }
  }

  // ================ Inne =================

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

  // Dla sync
  Future<void> markAsSynced(String uuid) async {
    try {
      final db = await _databaseService.database;
      await db.update('products', {'is_synced': 1}, where: 'uuid = ?', whereArgs: [uuid]);
    } catch (e) {
      AppLogger.error("Error marking product as synced: $e");
      throw Exception('Error marking product as synced: $e');
    }
  }
}
