class ProductEntity {
  int? id;
  String uuid;
  int userId;
  String name;
  String? manufacturer;
  int kcal;
  double carbs;
  double protein;
  double fat;
  DateTime createdAt;
  DateTime lastModifiedAt;
  bool fromModel;
  double? averagePortion;
  bool isSynced;

  ProductEntity({
    this.id,
    required this.uuid,
    required this.userId,
    required this.name,
    this.manufacturer,
    required this.kcal,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.createdAt,
    required this.lastModifiedAt,
    this.fromModel = false,
    this.averagePortion,
    this.isSynced = false,
  });
}
