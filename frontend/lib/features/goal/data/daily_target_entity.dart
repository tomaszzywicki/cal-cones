class DailyTargetEntity {
  final String date;
  final int userId;
  final int goalId;
  final double weightUsed;
  final String dietType;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final DateTime? lastModifiedAt;
  final bool isSynced;

  DailyTargetEntity({
    required this.date,
    required this.userId,
    required this.goalId,
    required this.weightUsed,
    required this.dietType,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.lastModifiedAt,
    this.isSynced = false,
  });
}
