class WeightEntryEntity {
  int? id;
  String? uuid;
  int? userId;
  double weight;
  DateTime date;
  DateTime createdAt;
  DateTime lastModifiedAt;
  bool isSynced;

  WeightEntryEntity({
    this.id,
    this.uuid,
    this.userId,
    required this.weight,
    required this.date,
    required this.createdAt,
    required this.lastModifiedAt,
    this.isSynced = false,
  });
}
