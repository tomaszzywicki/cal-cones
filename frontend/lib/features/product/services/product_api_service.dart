import 'package:frontend/core/network/api_client.dart';
import 'package:http/http.dart' as http;

class ProductApiService extends ApiClient {
  ProductApiService(super.firebaseAuthService);

  Future<http.Response> createProduct(Map<String, dynamic> data) {
    return post('/products', data);
  }

  Future<http.Response> updateProduct(String uuid, Map<String, dynamic> data) {
    return put('/products/$uuid', data);
  }

  Future<http.Response> deleteProduct(String uuid) {
    return delete('/products/$uuid');
  }

  Future<http.Response> getProducts() {
    return get('/products');
  }
}
