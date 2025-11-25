import 'package:frontend/features/meal/data/meal_entity.dart';

class MealModel extends MealEntity {
  MealModel({
    super.id,
    super.uuid,
    required super.userId,
    super.name,
    super.totalKcal,
    super.totalCarbs,
    super.totalProtein,
    super.totalFat,
    super.notes,
    super.consumedAt,
    super.createdAt,
    super.lastModifiedAt,
    super.isSynced = false,
  });

  // Backend API response parsing
  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      userId: json['user_id'] as int,
      name: json['name'] as String?,
      totalKcal: json['total_kcal'] as int?,
      totalCarbs: json['total_carbs'] as double?,
      totalProtein: json['total_protein'] as double?,
      totalFat: json['total_fat'] as double?,
      notes: json['notes'] as String?,
      consumedAt: json['consumed_at'] != null ? DateTime.parse(json['consumed_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      lastModifiedAt: json['last_modified_at'] != null
          ? DateTime.parse(json['last_modified_at'] as String)
          : null,
      isSynced: json['is_synced'] == 1,
    );
  }

  // MealModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'name': name,
      'total_kcal': totalKcal,
      'total_carbs': totalCarbs,
      'total_protein': totalProtein,
      'total_fat': totalFat,
      'notes': notes,
      'consumed_at': consumedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'last_modified_at': lastModifiedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // MealModel to Map for local db
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'name': name,
      'total_kcal': totalKcal,
      'total_carbs': totalCarbs,
      'total_protein': totalProtein,
      'total_fat': totalFat,
      'notes': notes,
      'consumed_at': consumedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'last_modified_at': lastModifiedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // MealModel from Map for local db
  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String?,
      userId: map['user_id'] as int,
      name: map['name'] as String?,
      totalKcal: map['total_kcal'] as int?,
      totalCarbs: map['total_carbs'] as double?,
      totalProtein: map['total_protein'] as double?,
      totalFat: map['total_fat'] as double?,
      notes: map['notes'] as String?,
      consumedAt: map['consumed_at'] != null ? DateTime.parse(map['consumed_at'] as String) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      lastModifiedAt: map['last_modified_at'] != null
          ? DateTime.parse(map['last_modified_at'] as String)
          : null,
      isSynced: map['is_synced'] == 1,
    );
  }

  MealModel copyWith({
    int? id,
    String? uuid,
    int? userId,
    String? name,
    int? totalKcal,
    double? totalCarbs,
    double? totalProtein,
    double? totalFat,
    String? notes,
    DateTime? consumedAt,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    bool? isSynced,
  }) {
    return MealModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      totalKcal: totalKcal ?? this.totalKcal,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalProtein: totalProtein ?? this.totalProtein,
      totalFat: totalFat ?? this.totalFat,
      notes: notes ?? this.notes,
      consumedAt: consumedAt ?? this.consumedAt,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
