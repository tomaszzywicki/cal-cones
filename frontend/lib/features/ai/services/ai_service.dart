import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/ai/data/ai_response.dart';
import 'package:frontend/features/ai/services/ai_api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class AIService {
  final AIApiService aiApiService;

  AIService({required this.aiApiService});

  Future<List<List<AIResponse>>> detectProducts(XFile image) async {
    try {
      final response = await aiApiService.detectProducts(image);

      if (response.statusCode != 200) {
        AppLogger.error('API Error: ${response.statusCode}. ${response.body}');
        throw Exception("Failed to detect products: ${response.statusCode}");
      }

      // Backend zwraca: [[{product: {...}, probability: 0.9}, ...], ...]
      final dynamic decodedBody = jsonDecode(response.body);

      if (decodedBody is! List) {
        throw Exception("Expected List, got ${decodedBody.runtimeType}");
      }

      final List<List<AIResponse>> result = [];

      for (final item in decodedBody) {
        if (item is! List) {
          AppLogger.warning("Skipping non-list item: $item");
          continue;
        }

        final predictions = <AIResponse>[];

        for (final prediction in item) {
          if (prediction is! Map<String, dynamic>) {
            AppLogger.warning("Skipping non-map prediction: $prediction");
            continue;
          }

          try {
            predictions.add(AIResponse.fromMap(prediction));
          } catch (e) {
            AppLogger.error("Failed to parse prediction: $e");
          }
        }

        if (predictions.isNotEmpty) {
          result.add(predictions);
        }
      }

      AppLogger.info(
        "Detected ${result.length} objects with ${result.fold(0, (sum, list) => sum + list.length)} total predictions",
      );
      return result;
    } catch (e) {
      AppLogger.error('Error during detecting products: $e');
      rethrow;
    }
  }
}
