class AIResponse {
  String name;
  double probability;

  AIResponse({required this.name, required this.probability});

  factory AIResponse.fromMap(Map<String, dynamic> map) {
    return AIResponse(name: map['name'] as String, probability: (map['probability'] as num).toDouble());
  }
}
