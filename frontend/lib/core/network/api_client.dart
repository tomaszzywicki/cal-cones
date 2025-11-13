import 'dart:convert';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://192.168.0.107:8000';
  final FirebaseAuthService _firebaseAuthService;

  ApiClient(this._firebaseAuthService);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _firebaseAuthService.currentUser!.getIdToken();
    return {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.post(Uri.parse('$baseUrl$endpoint'), body: json.encode(body), headers: headers);
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.put(Uri.parse('$baseUrl$endpoint'), body: json.encode(body), headers: headers);
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }
}
