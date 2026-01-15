import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/services/weight_log_repository.dart';

class WeightLogService extends ChangeNotifier {
  final WeightLogRepository _weightLogRepository;
  final int? _userId;
  static const int OUTDATED_THRESHOLD_DAYS = 30;

  late List<WeightEntryModel> _entries = [];

  WeightLogService(this._userId, this._weightLogRepository) {
    if (_userId == null) {
      AppLogger.debug('[WeightLogService] No user ID provided, skipping data initialization.');
      return;
    }
    AppLogger.debug('[WeightLogService] Initializing weight log data for user ID: $_userId');
    _initData();
  }

  Future<void> _initData() async {
    _entries = await _weightLogRepository.getWeightEntries(_userId!);
    notifyListeners();
  }

  List<WeightEntryModel> get entries => _entries;
  WeightEntryModel? get latestEntry => _entries.isNotEmpty ? _entries.first : null;

  Future<void> addWeightEntry(WeightEntryModel weightEntry) async {
    final int newId = await _weightLogRepository.addWeightEntry(weightEntry, _userId!);

    weightEntry.id = newId;
    _entries.add(weightEntry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteWeightEntry(WeightEntryModel weightEntry) async {
    _entries.removeWhere((entry) => entry.id == weightEntry.id);
    notifyListeners();

    await _weightLogRepository.deleteWeightEntry(weightEntry);
  }

  bool entryExistsWithDate(DateTime date) {
    return _entries.any(
      (entry) => entry.date.year == date.year && entry.date.month == date.month && entry.date.day == date.day,
    );
  }

  Future<WeightEntryModel?> getEntryByDate(DateTime date) async {
    try {
      return _entries.firstWhere(
        (entry) =>
            entry.date.year == date.year && entry.date.month == date.month && entry.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<WeightEntryModel?> getLatestWeightEntry(int userId) async {
    try {
      return _entries.isNotEmpty ? _entries.first : null;
    } catch (e) {
      AppLogger.error('WeightLogService.getLatestWeightEntry error: $e');
      throw Exception('Failed to get latest weight entry: $e');
    }
  }

  Future<void> changeWeightForEntry(WeightEntryModel? oldEntry, double weight) async {
    if (oldEntry == null) return;
    oldEntry.changeWeight(weight);
    notifyListeners();

    await _weightLogRepository.updateWeightEntry(oldEntry);
  }

  Future<bool> hasWeightData(int userId) async {
    try {
      final entries = await _weightLogRepository.getWeightEntries(userId);
      return entries.isNotEmpty;
    } catch (e) {
      AppLogger.error('WeightLogService: Failed to check for weight data.', e);
      return false;
    }
  }

  Future<bool> isLatestEntryOutdated() async {
    final latestEntry = await getLatestWeightEntry(_userId!);
    if (latestEntry == null) return true;

    final now = DateTime.now();
    final difference = now.difference(latestEntry.date).inDays;
    return difference > OUTDATED_THRESHOLD_DAYS;
  }
}
