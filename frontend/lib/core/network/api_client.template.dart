import 'dart:convert';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  // ─────────────────────────────────────────────────────────────
  // DO NOT CHANGE the value in this file!
  // This is a TEMPLATE for version control.
  //
  // You will probably need to configure 'baseUrl' to match the IP adress of your machine.
  // Change the value of 'baseUrl' in api_client.dart within the same directory, not here
  // if you don't have api_client.dart in the same directory as api_client.template.dart:
  //    copy api_client.template.dart and rename it as api_client.dart
  //    remove lines 6-16 within your new api_clinet.dart
  // ─────────────────────────────────────────────────────────────

  // Make sure to change baseUrl to match the IP adress of your machine
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
