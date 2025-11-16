class GoalEntity {
  int? id;
  String? uuid;
  int userId;
  DateTime startDate;
  DateTime targetDate;
  DateTime? endDate;
  double startWeight;
  double targetWeight;
  double? endWeight;
  double tempo; // kg/week
  bool isCurrent;

  GoalEntity({
    this.id,
    this.uuid,
    required this.userId,
    required this.startDate,
    required this.targetDate,
    this.endDate,
    required this.startWeight,
    required this.targetWeight,
    this.endWeight,
    required this.tempo,
    required this.isCurrent,
  });
}
