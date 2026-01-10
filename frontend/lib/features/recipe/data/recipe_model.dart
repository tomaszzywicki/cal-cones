import 'dart:convert';

class RecipeModel {
  final int? id;
  final String name;
  final String time;
  final int calories;
  final List<String> ingredients;
  final List<String> instructions;
  final DateTime createdAt;

  RecipeModel({
    this.id,
    required this.name,
    required this.time,
    required this.calories,
    required this.ingredients,
    required this.instructions,
    required this.createdAt,
  });

  // Convert from Map (Database)
  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      time: map['time'] as String,
      calories: map['calories'] as int,
      ingredients: List<String>.from(jsonDecode(map['ingredients'])),
      instructions: List<String>.from(jsonDecode(map['instructions'])),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Convert to Map (Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'calories': calories,
      'ingredients': jsonEncode(ingredients),
      'instructions': jsonEncode(instructions),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert from API JSON (Gemini Response)
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      name: json['recipe_name'] ?? 'Unknown Recipe',
      time: json['time'] ?? 'Unknown time',
      calories: json['calories'] is int ? json['calories'] : 0,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      createdAt: DateTime.now(),
    );
  }
}