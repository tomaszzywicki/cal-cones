import 'package:frontend/features/meal/data/meal_product_entity.dart';
import 'package:uuid/uuid.dart';

class MealProductModel extends MealProductEntity {
  MealProductModel({
    super.id,
    required super.uuid,
    // super.mealId,
    // super.mealUuid,
    super.userId,
    required super.productId,
    super.productUuid,
    required super.name,
    super.manufacturer,
    required super.kcal,
    required super.carbs,
    required super.protein,
    required super.fat,
    required super.unitId,
    required super.unitShort,
    required super.conversionFactor,
    required super.amount,
    super.notes,
    required super.createdAt,
    required super.lastModifiedAt,
    super.isSynced = false,
  });

  static MealProductModel fromProductWithAmount({
    required int productId,
    required String name,
    String? manufacturer,
    required num baseKcal, // to na 100g
    required num baseCarbs,
    required num baseProtein,
    required num baseFat,
    required double amount, // ilość faktyczna
    required int unitId,
    required String unitShort,
    required double conversionFactor, // conversion
    required DateTime consumedAt,
    int? userId,
  }) {
    final factor = amount * conversionFactor / 100;

    return MealProductModel(
      uuid: Uuid().v4(),
      userId: userId,
      productId: productId,
      name: name,
      manufacturer: manufacturer,
      kcal: (baseKcal * factor).round(),
      carbs: (baseCarbs * factor),
      protein: (baseProtein * factor),
      fat: (baseFat * factor),
      unitId: unitId,
      unitShort: unitShort,
      conversionFactor: conversionFactor,
      amount: amount,
      createdAt: consumedAt,
      lastModifiedAt: DateTime.now().toUtc(),
      isSynced: false,
    );
  }

  MealProductModel updateAmount(double newAmount) {
    if (amount <= 0 || conversionFactor <= 0) {
      throw ArgumentError('Invalid amount or conversion factor');
    }
    final currentFactor = amount * conversionFactor / 100.0;
    final baseKcal = kcal / currentFactor;
    final baseCarbs = carbs / currentFactor;
    final baseProtein = protein / currentFactor;
    final baseFat = fat / currentFactor;

    final newFactor = newAmount * conversionFactor / 100.0;

    return copyWith(
      amount: newAmount,
      kcal: (baseKcal * newFactor).round(),
      carbs: baseCarbs * newFactor,
      protein: baseProtein * newFactor,
      fat: baseFat * newFactor,
      lastModifiedAt: DateTime.now().toUtc(),
      isSynced: false,
    );
  }

  // Backend API response parsing
  factory MealProductModel.fromJson(Map<String, dynamic> json) {
    return MealProductModel(
      // id: json['id'] as int?,
      uuid: json['uuid'] as String,
      // mealId: json['meal_id'] as int,
      // mealUuid: json['meal_uuid'] as String?,
      userId: json['user_id'] as int,
      productId: json['product_id'] as int,
      productUuid: json['product_uuid'] as String?,
      name: json['name'] as String,
      manufacturer: json['manufacturer'] as String?,
      kcal: json['kcal'] as int,
      carbs: (json['carbs'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      unitId: json['unit_id'] as int,
      unitShort: json['unit_short'] as String,
      conversionFactor: (json['conversion_factor'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['last_modified_at'] as String),
      isSynced: json['is_synced'] == 1,
    );
  }

  // MealProductModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      // 'meal_id': mealId,
      // 'meal_uuid': mealUuid,
      'user_id': userId,
      'product_id': productId,
      'product_uuid': productUuid,
      'name': name,
      'manufacturer': manufacturer,
      'kcal': kcal,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'unit_id': unitId,
      'unit_short': unitShort,
      'conversion_factor': conversionFactor,
      'amount': amount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'last_modified_at': lastModifiedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // MealProductModel to Map for local db
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      // 'meal_id': mealId,
      // 'meal_uuid': mealUuid,
      'user_id': userId,
      'product_id': productId,
      'product_uuid': productUuid,
      'name': name,
      'manufacturer': manufacturer,
      'kcal': kcal,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'unit_id': unitId,
      'unit_short': unitShort,
      'conversion_factor': conversionFactor,
      'amount': amount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'last_modified_at': lastModifiedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // MealProductModel from Map for local db
  factory MealProductModel.fromMap(Map<String, dynamic> map) {
    return MealProductModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      // mealId: map['meal_id'] as int,
      // mealUuid: map['meal_uuid'] as String?,
      userId: map['user_id'] as int,
      productId: map['product_id'] as int,
      productUuid: map['product_uuid'] as String?,
      name: map['name'] as String,
      manufacturer: map['manufacturer'] as String?,
      kcal: map['kcal'] as int,
      carbs: (map['carbs'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      unitId: map['unit_id'] as int,
      unitShort: map['unit_short'] as String,
      conversionFactor: (map['conversion_factor'] as num).toDouble(),
      amount: (map['amount'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastModifiedAt: DateTime.parse(map['last_modified_at'] as String),
      isSynced: map['is_synced'] == 1,
    );
  }

  MealProductModel copyWith({
    int? id,
    String? uuid,
    int? mealId,
    String? mealUuid,
    int? userId,
    int? productId,
    String? productUuid,
    String? name,
    String? manufacturer,
    int? kcal,
    double? carbs,
    double? protein,
    double? fat,
    int? unitId,
    String? unitShort,
    double? conversionFactor,
    double? amount,
    String? notes,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    bool? isSynced,
  }) {
    return MealProductModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      // mealId: mealId ?? this.mealId,
      // mealUuid: mealUuid ?? this.mealUuid,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productUuid: productUuid ?? this.productUuid,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      kcal: kcal ?? this.kcal,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      unitId: unitId ?? this.unitId,
      unitShort: unitShort ?? this.unitShort,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  double get totalGrams => amount * conversionFactor;

  String get displayAmount {
    if (unitShort == 'g') {
      return '${amount.toStringAsFixed(0)}g';
    }
    return '${amount.toStringAsFixed(1)} $unitShort (${totalGrams.toStringAsFixed(0)}g)';
  }
}
