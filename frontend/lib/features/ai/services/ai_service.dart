import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/ai/data/ai_response.dart';
import 'package:frontend/features/ai/services/ai_api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class AIService {
  AIApiService aiApiService;

  AIService({required this.aiApiService});

  Future<List<List<AIResponse>>> detectProducts(XFile image) async {
    try {
      final response = await aiApiService.detectProducts(image);
      if (response.statusCode != 200) {
        AppLogger.error('API Error: ${response.statusCode}. ${response.body}');
        throw Exception("Failed to detect products: ${response.statusCode}");
      }

      final List<List<dynamic>> decodedBody = jsonDecode(response.body);
      return decodedBody.map((innerList) => innerList.map((e) => AIResponse.fromMap(e)).toList()).toList();
    } catch (e) {
      AppLogger.error('Error during detecting products: $e');
      rethrow;
    }
  }
}
