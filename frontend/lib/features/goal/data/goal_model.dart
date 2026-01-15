import 'package:frontend/features/goal/data/goal_entity.dart';

class GoalModel extends GoalEntity {
  GoalModel({
    super.id,
    super.uuid,
    required super.userId,
    required super.startDate,
    required super.targetDate,
    super.endDate,
    required super.startWeight,
    required super.targetWeight,
    super.endWeight,
    required super.tempo,
    required super.isCurrent,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      userId: json['user_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      targetDate: DateTime.parse(json['target_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      startWeight: (json['start_weight'] as num).toDouble(),
      targetWeight: (json['target_weight'] as num).toDouble(),
      endWeight: json['end_weight'] != null ? (json['end_weight'] as num).toDouble() : null,
      tempo: (json['tempo'] as num).toDouble(),
      isCurrent: (json['is_current'] as int) == 1 || (json['is_current'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'target_date': targetDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'start_weight': startWeight,
      'target_weight': targetWeight,
      'end_weight': endWeight,
      'tempo': tempo,
      'is_current': isCurrent ? 1 : 0,
    };
  }

  GoalModel copyWith({
    int? id,
    String? uuid,
    int? userId,
    DateTime? startDate,
    DateTime? targetDate,
    DateTime? endDate,
    double? startWeight,
    double? targetWeight,
    double? endWeight,
    double? tempo,
    bool? isCurrent,
  }) {
    return GoalModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      endDate: endDate ?? this.endDate,
      startWeight: startWeight ?? this.startWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      endWeight: endWeight ?? this.endWeight,
      tempo: tempo ?? this.tempo,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  double get totalWeightChange => targetWeight - startWeight;
  bool get isWeightLoss => totalWeightChange < 0;
}
