import 'dart:convert';
import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/core/sync/sync_operation.dart';

class SyncQueueRepository {
  final LocalDatabaseService _databaseService;

  SyncQueueRepository(this._databaseService);

  Future<void> add(SyncOperation operation) async {
    final db = await _databaseService.database;
    await db.insert('sync_queue', operation.toMap());
  }

  Future<List<SyncOperation>> getByFeature(String feature) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'sync_queue',
      where: 'feature = ?',
      whereArgs: [feature],
      orderBy: 'created_at ASC',
    );
    return result.map((row) => SyncOperation.fromMap(row)).toList();
  }

  Future<List<SyncOperation>> getByEntityUuid(String entityUuid) async {
    final db = await _databaseService.database;
    final result = await db.query('sync_queue', where: 'entity_uuid = ?', whereArgs: [entityUuid]);
    return result.map((row) => SyncOperation.fromMap(row)).toList();
  }

  Future<bool> hasCreateOperation(String entityUuid) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'sync_queue',
      where: 'entity_uuid = ? AND operation = ?',
      whereArgs: [entityUuid, 'create'],
    );
    return result.isNotEmpty;
  }

  Future<void> updatePayload(int id, Map<String, dynamic> payload) async {
    final db = await _databaseService.database;
    await db.update('sync_queue', {'payload': jsonEncode(payload)}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> remove(int id) async {
    final db = await _databaseService.database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeByEntityUuid(String entityUuid) async {
    final db = await _databaseService.database;
    await db.delete('sync_queue', where: 'entity_uuid = ?', whereArgs: [entityUuid]);
  }

  Future<void> removeByEntityUuidAndOperation(String entityUuid, SyncOperationType operation) async {
    final db = await _databaseService.database;
    await db.delete(
      'sync_queue',
      where: 'entity_uuid = ? AND operation = ?',
      whereArgs: [entityUuid, operation.name],
    );
  }
}
