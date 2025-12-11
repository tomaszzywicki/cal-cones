import 'package:frontend/features/weight_log/data/weight_entry_entity.dart';

class WeightEntryModel extends WeightEntryEntity {
  WeightEntryModel({
    super.id,
    super.uuid,
    super.userId,
    required super.weight,
    required super.date,
    required super.createdAt,
    required super.lastModifiedAt,
    super.isSynced = false,
  });

  static WeightEntryModel create({required double weight, required DateTime date, int? userId}) {
    final now = DateTime.now().toUtc();

    return WeightEntryModel(
      userId: userId,
      weight: weight,
      date: date,
      createdAt: now,
      lastModifiedAt: now,
      isSynced: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'weight': weight,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'last_modified_at': lastModifiedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory WeightEntryModel.fromMap(Map<String, dynamic> map) {
    return WeightEntryModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String?,
      userId: map['user_id'] as int?,
      weight: (map['weight'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      lastModifiedAt: DateTime.parse(map['last_modified_at'] as String),
      isSynced: (map['is_synced'] as int) == 1,
    );
  }

  int daysSinceToday() {
    return date.difference(DateTime.now().toUtc()).inDays;
  }
}
