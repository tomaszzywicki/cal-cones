import 'dart:convert';

enum SyncOperationType { create, update, delete }

class SyncOperation {
  final int? id;
  final String feature;
  final SyncOperationType operation;
  final String entityUuid;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;

  SyncOperation({
    this.id,
    required this.feature,
    required this.operation,
    required this.entityUuid,
    this.payload,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'feature': feature,
      'operation': operation.name,
      'entity_uuid': entityUuid,
      'payload': payload != null ? jsonEncode(payload) : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'] as int?,
      feature: map['feature'] as String,
      operation: SyncOperationType.values.byName(map['operation'] as String),
      entityUuid: map['entity_uuid'] as String,
      payload: map['payload'] != null ? jsonDecode(map['payload'] as String) as Map<String, dynamic> : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
