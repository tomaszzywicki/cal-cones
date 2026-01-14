import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/goal/data/goal_model.dart';
import 'package:frontend/features/goal/services/goal_repository.dart';
import 'package:frontend/core/logger/app_logger.dart';

class GoalService {
  final GoalRepository _goalRepository;
  final CurrentUserService _currentUserService;

  GoalService(this._goalRepository, this._currentUserService);

  Future<void> clearGoals() async {
    try {
      final userId = _currentUserService.getUserId();
      await _goalRepository.clearGoals(userId);
      AppLogger.info('GoalService: All goals cleared successfully.');
    } catch (e) {
      AppLogger.error('GoalService: Failed to clear goals.', e);
      rethrow;
    }
  }

  Future<void> createGoal(GoalModel goal) async {
    try {
      await _goalRepository.createGoal(goal);
      AppLogger.info('GoalService: Goal created successfully.');
    } catch (e) {
      AppLogger.error('GoalService: Failed to create goal.', e);
      rethrow;
    }
  }

  /// Ustawia nowy cel, automatycznie zamykając poprzedni
  Future<void> setNewGoal(GoalModel newGoal) async {
    try {
      // 1. Pobierz aktualny cel
      final userId = _currentUserService.getUserId();
      final currentGoal = await _goalRepository.getActiveGoal(userId);

      if (currentGoal != null) {
        // 2. Zamknij stary cel (ustaw datę końca i flagę is_current)
        // Zakładamy, że GoalModel ma metodę copyWith
        // lub tworzymy nowy obiekt ręcznie, jeśli copyWith nie obsługuje nulli w specyficzny sposób
        final closedGoal = GoalModel(
          id: currentGoal.id,
          uuid: currentGoal.uuid,
          userId: currentGoal.userId,
          startDate: currentGoal.startDate,
          targetDate: currentGoal.targetDate,
          endDate: DateTime.now(), // Zamykamy dzisiaj
          startWeight: currentGoal.startWeight,
          targetWeight: currentGoal.targetWeight,
          endWeight: currentGoal.endWeight, // Tu można wstawić aktualną wagę jeśli mamy pod ręką
          tempo: currentGoal.tempo,
          isCurrent: false, // Już nie jest aktualny
        );

        await _goalRepository.updateGoal(closedGoal);
      }

      // 3. Zapisz nowy cel (jako aktualny)
      // Upewnij się, że newGoal ma isCurrent = true i endDate = null
      await _goalRepository.createGoal(newGoal);

      AppLogger.info('GoalService: New goal set successfully.');
    } catch (e) {
      AppLogger.error('GoalService: Failed to set new goal.', e);
      rethrow;
    }
  }

  Future<GoalModel?> getActiveGoal() {
    final userId = _currentUserService.getUserId();
    return _goalRepository.getActiveGoal(userId);
  }

  Future<GoalModel?> createGenericMaintenanceGoal(double userWeight) async {
    try {
      final userId = _currentUserService.getUserId();
      final genericGoal = GoalModel(
        id: -1,
        userId: userId,
        startDate: DateTime.now(),
        targetDate: DateTime.now().add(Duration(days: 30)),
        endDate: null,
        startWeight: userWeight, // Przykładowa waga startowa
        targetWeight: userWeight, // Cel utrzymania wagi
        endWeight: null,
        tempo: 0.0, // Brak zmiany wagi
        isCurrent: true,
      );
      AppLogger.info('GoalService: Generic maintenance goal created successfully.');
      return genericGoal;
    } catch (e) {
      AppLogger.error('GoalService: Failed to create generic maintenance goal.', e);
      rethrow;
    }
  }

  Future<List<GoalModel>> getGoalHistory() async {
    try {
      final userId = _currentUserService.getUserId();
      return await _goalRepository.getGoalHistory(userId);
    } catch (e) {
      AppLogger.error('GoalService: Failed to fetch goal history.', e);
      rethrow;
    }
  }

  Future<bool> hasActiveGoal(int userId) async {
    try {
      final activeGoal = await _goalRepository.getActiveGoal(userId);
      return activeGoal != null;
    } catch (e) {
      AppLogger.error('GoalService: Failed to check for active goal.', e);
      return false;
    }
  }
}
