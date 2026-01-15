import 'package:frontend/features/goal/data/daily_target_entity.dart';

class DailyTargetModel extends DailyTargetEntity {
  DailyTargetModel({
    required super.date,
    required super.userId,
    required super.goalId,
    required super.weightUsed,
    required super.calories,
    required super.proteinG,
    required super.carbsG,
    required super.fatG,
    required super.dietType,
    required super.lastModifiedAt,
    super.isSynced = false,
  });

  // Backend API response parsing
  factory DailyTargetModel.fromJson(Map<String, dynamic> json) {
    return DailyTargetModel(
      date: json['date'] as String,
      userId: json['user_id'] as int,
      goalId: json['goal_id'] as int,
      weightUsed: (json['weight_used'] as num).toDouble(),
      calories: json['calories'] as int,
      proteinG: json['protein_g'] as int,
      carbsG: json['carbs_g'] as int,
      fatG: json['fat_g'] as int,
      dietType: json['diet_type'] as String,
      lastModifiedAt: json['last_modified_at'] != null
          ? DateTime.parse(json['last_modified_at'] as String)
          : null,
      isSynced: json['is_synced'] == 1,
    );
  }

  // DailyTargetModel to Map for local db
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'user_id': userId,
      'goal_id': goalId,
      'weight_used': weightUsed,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'diet_type': dietType,
      'last_modified_at': lastModifiedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory DailyTargetModel.fromMap(Map<String, dynamic> map) {
    return DailyTargetModel(
      date: map['date'] as String,
      userId: map['user_id'] as int,
      goalId: map['goal_id'] as int,
      weightUsed: (map['weight_used'] as num).toDouble(),
      calories: map['calories'] as int,
      proteinG: map['protein_g'] as int,
      carbsG: map['carbs_g'] as int,
      fatG: map['fat_g'] as int,
      dietType: map['diet_type'] as String,
      lastModifiedAt: map['last_modified_at'] != null
          ? DateTime.parse(map['last_modified_at'] as String)
          : null,
      isSynced: map['is_synced'] == 1,
    );
  }

  DailyTargetModel copyWith({
    String? date,
    int? userId,
    int? goalId,
    double? weightUsed,
    String? dietType,
    int? calories,
    int? proteinG,
    int? carbsG,
    int? fatG,
    DateTime? lastModifiedAt,
    bool? isSynced,
  }) {
    return DailyTargetModel(
      date: date ?? this.date,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      weightUsed: weightUsed ?? this.weightUsed,
      dietType: dietType ?? this.dietType,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
