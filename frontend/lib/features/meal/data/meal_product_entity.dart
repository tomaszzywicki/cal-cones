class MealProductEntity {
  int? id;
  String uuid;
  // int? mealId;
  // String? mealUuid;
  int? userId;
  // int productId;
  String productUuid;
  String name;
  String? manufacturer;
  int kcal;
  double carbs;
  double protein;
  double fat;
  int unitId;
  String unitShort;
  double conversionFactor;
  double amount;
  String? notes;
  DateTime createdAt;
  DateTime lastModifiedAt;
  bool isSynced;

  MealProductEntity({
    this.id,
    required this.uuid,
    // required this.mealId,
    // this.mealUuid,
    required this.userId,
    // required this.productId,
    required this.productUuid,
    required this.name,
    this.manufacturer,
    required this.kcal,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.unitId,
    required this.unitShort,
    required this.conversionFactor,
    required this.amount,
    this.notes,
    required this.createdAt,
    required this.lastModifiedAt,
    this.isSynced = false,
  });
}
