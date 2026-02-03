import 'package:frontend/core/network/api_client.dart';
import 'package:http/http.dart' as http;

class MealApiService extends ApiClient {
  MealApiService(super._firebaseAuthService);

  static const String name = 'meal-product';

  Future<http.Response> createMealProduct(Map<String, dynamic> data) {
    return post('/$name/create', data);
  }

  Future<http.Response> updateMealProduct(Map<String, dynamic> data) {
    return put('/$name/update', data);
  }

  Future<http.Response> deleteMealProduct(String uuid) {
    return delete('/$name/delete/$uuid');
  }

  Future<http.Response> getUserMealProducts() {
    return get('/$name/all');
  }
}
