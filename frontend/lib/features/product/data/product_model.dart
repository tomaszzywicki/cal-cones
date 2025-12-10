import 'package:frontend/features/product/data/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    super.id,
    required super.uuid,
    required super.userId,
    required super.name,
    super.manufacturer,
    required super.kcal,
    required super.carbs,
    required super.protein,
    required super.fat,
    required super.createdAt,
    required super.lastModifiedAt,
    super.fromModel = false,
    super.averagePortion,
    super.isSynced = false,
  });

  // Backend API response parsing
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      manufacturer: json['manufacturer'] as String?,
      kcal: json['kcal'] as int,
      carbs: (json['carbs'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['last_modified_at'] as String),
      fromModel: json['from_model'] == 1,
      averagePortion: (json['average_portion'] as num).toDouble(),
      isSynced: json['is_synced'] == 1,
    );
  }

  // ProductModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'name': name,
      'manufacturer': manufacturer,
      'kcal': kcal,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'created_at': createdAt.toIso8601String(),
      'last_modified_at': lastModifiedAt.toIso8601String(),
      'from_model': fromModel ? 1 : 0,
      'average_portion': averagePortion,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // ProductModel to Map for local db
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'name': name,
      'manufacturer': manufacturer,
      'kcal': kcal,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'created_at': createdAt.toIso8601String(),
      'last_modified_at': lastModifiedAt.toIso8601String(),
      'from_model': fromModel ? 1 : 0,
      'average_portion': averagePortion,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // ProductModel from Map for local db
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      manufacturer: map['manufacturer'] as String?,
      kcal: map['kcal'] as int,
      carbs: (map['carbs'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      lastModifiedAt: DateTime.parse(map['last_modified_at'] as String),
      fromModel: map['from_model'] == 1,
      averagePortion: map['average_portion'] != null ? (map['average_portion'] as num).toDouble() : null,
      isSynced: map['is_synced'] == 1,
    );
  }

  ProductModel copyWith({
    int? id,
    String? uuid,
    int? userId,
    String? name,
    String? manufacturer,
    int? kcal,
    double? carbs,
    double? protein,
    double? fat,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    bool? fromModel,
    double? averagePortion,
    bool? isSynced,
  }) {
    return ProductModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      kcal: kcal ?? this.kcal,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      fromModel: fromModel ?? this.fromModel,
      averagePortion: averagePortion ?? this.averagePortion,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
