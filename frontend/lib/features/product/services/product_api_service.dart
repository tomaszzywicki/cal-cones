import 'package:frontend/core/network/api_client.dart';
import 'package:http/http.dart' as http;

class ProductApiService extends ApiClient {
  ProductApiService(super.firebaseAuthService);

  Future<http.Response> createProduct(Map<String, dynamic> data) {
    return post('/products/create', data);
  }

  Future<http.Response> updateProduct(String uuid, Map<String, dynamic> data) {
    return put('/products/update', data);
  }

  Future<http.Response> deleteProduct(String uuid) {
    return delete('/products/delete/$uuid');
  }

  Future<http.Response> searchProducts(String query) {
    return get('/products/$query');
  }
}
