import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/goal/data/daily_target_model.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/goal/services/daily_target_calculator_service.dart';
import 'package:frontend/features/goal/services/daily_target_repository.dart';
import 'package:frontend/features/goal/services/goal_service.dart';
import 'package:frontend/features/user/services/user_service.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:intl/intl.dart';

class DailyTargetService {
  final DailyTargetRepository _dailyTargetRepository;
  final CurrentUserService _currentUserService;
  final GoalService _goalService;
  final WeightLogService _weightLogService;
  final DailyTargetCalculatorService _calculatorService;

  DailyTargetService(
    this._dailyTargetRepository,
    this._currentUserService,
    this._goalService,
    this._weightLogService,
    this._calculatorService,
  );

  Future<void> ensureHistoryIsPopulated() async {
    final userId = _currentUserService.currentUser?.id;
    if (userId == null) {
      throw Exception('No authenticated user found.');
    }

    // Get the date for the first missing daily target entry
    final lastDateStr = await _dailyTargetRepository.getLastEntryDate(userId);
    final today = DateTime.now().toUtc();

    DateTime startDate;
    final goal = await _goalService.getActiveGoal();
    if (goal == null) {
      throw Exception('No active goal found for user ID: $userId');
    }

    if (lastDateStr == null) {
      startDate = goal.startDate;
    } else {
      final lastDate = DateTime.parse(lastDateStr);
      startDate = lastDate.add(Duration(days: 1));
    }

    if (startDate.isAfter(today)) {
      // History is already up to date
      return;
    }

    // Figure out daily targets from startDate to today (they will be the same as nothing was changing in between)
    final currentWeightEntry = await _weightLogService.getLatestWeightEntry();
    if (currentWeightEntry == null) {
      throw Exception('No weight entries found for user ID: $userId');
    }
    final currentWeight = currentWeightEntry.weight;
    final dailyTarget = _calculatorService.calculateDailyTarget(
      _currentUserService.currentUser!,
      goal,
      currentWeight,
    );

    // Fill daily targets in the database
    int filledDays = 0;
    DateTime dateCursor = startDate;
    while (dateCursor.isBefore(today) || dateCursor.isAtSameMomentAs(today)) {
      DailyTargetModel dailyTargetModel = dailyTarget.copyWith(date: _dateToString(dateCursor));
      await _dailyTargetRepository.saveDailyTarget(dailyTargetModel);
      dateCursor = dateCursor.add(Duration(days: 1));
      filledDays++;
    }
    AppLogger.info(
      'DailyTargetService: Filled $filledDays days of daily targets from ${_dateToString(startDate)} to ${_dateToString(today)} for user ID: $userId',
    );
  }

  Future<void> refreshTargetForToday() async {
    // await ensureHistoryIsPopulated();
    final userId = _currentUserService.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user found.');

    final today = DateTime.now().toUtc();

    final currentWeightEntry = await _weightLogService.getLatestWeightEntry();
    final fallbackWeight = _currentUserService.currentUser!.sex == 'female' ? 60.0 : 75.0;
    final currentWeight = currentWeightEntry?.weight ?? fallbackWeight;

    GoalModel? goal = await _goalService.getActiveGoal();

    if (goal == null) {
      AppLogger.warning(
        'DailyTargetService: No active goal found for user ID: $userId. Calculating maintenance target.',
      );
      goal = await _goalService.createGenericMaintenanceGoal(currentWeight);
    }

    final todaysTarget = _calculatorService.calculateDailyTarget(
      _currentUserService.currentUser!,
      goal!,
      currentWeight,
    );

    DailyTargetModel dailyTargetModel = todaysTarget.copyWith(date: _dateToString(today));
    await _dailyTargetRepository.saveDailyTarget(dailyTargetModel);
    AppLogger.info('DailyTargetService: Refreshed daily target for today for user ID: $userId');
  }

  Future<DailyTargetModel?> getDailyTargetForDate(DateTime date) async {
    final userId = _currentUserService.currentUser?.id;
    if (userId == null) {
      throw Exception('No authenticated user found.');
    }

    final dateStr = _dateToString(date.toUtc());
    return await _dailyTargetRepository.getDailyTargetForDate(userId, dateStr);
  }

  String _dateToString(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
