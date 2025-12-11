import 'dart:convert';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiClient {
  static const String baseUrl = 'http://34.56.130.107:8000';
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

  Future<http.Response> postMultipart(String endpoint, String fieldName, XFile file) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    final token = await _firebaseAuthService.currentUser!.getIdToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}
