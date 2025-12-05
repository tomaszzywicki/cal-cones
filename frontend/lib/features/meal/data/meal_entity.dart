class MealEntity {
  int? id;
  String? uuid;
  int? userId;
  String? name;
  int? totalKcal;
  double? totalCarbs;
  double? totalProtein;
  double? totalFat;
  String? notes;
  DateTime? consumedAt;
  DateTime? createdAt;
  DateTime? lastModifiedAt;
  bool isSynced;

  MealEntity({
    this.id,
    this.uuid,
    required this.userId,
    this.name,
    this.totalKcal,
    this.totalCarbs,
    this.totalProtein,
    this.totalFat,
    this.notes,
    this.consumedAt,
    this.createdAt,
    this.lastModifiedAt,
    this.isSynced = false,
  });
}
