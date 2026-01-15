import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/recipe/data/recipe_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class RecipeService {
  final LocalDatabaseService _dbService;

  final String _apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';

  RecipeService(this._dbService);

  // --- Local Database Operations ---

  Future<int> saveRecipe(RecipeModel recipe) async {
    final db = await _dbService.database;
    final id = await db.insert('recipes', recipe.toMap());
    AppLogger.info('Recipe saved with ID: $id');
    return id;
  }

  Future<List<RecipeModel>> getSavedRecipes() async {
    final db = await _dbService.database;
    final result = await db.query('recipes', orderBy: 'created_at DESC');
    return result.map((row) => RecipeModel.fromMap(row)).toList();
  }

  Future<void> deleteRecipe(int id) async {
    final db = await _dbService.database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  // --- AI Generation ---

  Future<RecipeModel> generateRecipe(List<String> ingredients, String mealType) async {
    if (_apiKey.isEmpty) {
      throw Exception("GOOGLE_API_KEY not found in .env");
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );

      final ingredientsStr = ingredients.join(", ");
      final prompt =
          '''
      You are a professional chef.
      Create a $mealType recipe using these ingredients: $ingredientsStr.
      You do not have to use all of them. You have to use just the ones
      that will make a "normal" eatable meal, but you can also be a little
      bit creative and spontaneous.
      Assume basic pantry items (oil, salt, pepper) are available.
      
      Return ONLY JSON format. Do not return a list, just a single object:
      {
        "recipe_name": "Name of the dish",
        "time": "Time (e.g. 15 min)",
        "calories": 500,
        "ingredients": ["List of ingredients"],
        "instructions": ["Step 1", "Step 2"]
      }
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null) {
        throw Exception("Empty response from AI");
      }

      String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();

      final dynamic decoded = jsonDecode(cleanJson);
      Map<String, dynamic> jsonMap;

      if (decoded is Map<String, dynamic>) {
        jsonMap = decoded;
      } else if (decoded is List && decoded.isNotEmpty) {
        jsonMap = decoded.first as Map<String, dynamic>;
      } else {
        throw Exception("Unexpected JSON format: ${decoded.runtimeType}");
      }

      return RecipeModel.fromJson(jsonMap);
    } catch (e) {
      AppLogger.error("Recipe generation failed: $e");
      throw Exception("Failed to generate recipe: $e");
    }
  }
}
