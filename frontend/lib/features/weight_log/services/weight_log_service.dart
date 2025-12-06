import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/weight_log/data/weight_entry_model.dart';
import 'package:frontend/features/weight_log/services/weight_log_repository.dart';

class WeightLogService {
  final CurrentUserService _currentUserService;
  final WeightLogRepository _weightLogRepository;

  WeightLogService(this._currentUserService, this._weightLogRepository);

  // Future<double> getCurrentUserWeight() async {}

  Future<void> addWeightEntry(WeightEntryModel weightEntry) async {
    final userId = _currentUserService.getUserId();
    await _weightLogRepository.addWeightEntry(weightEntry, userId);
  }

  Future<List<WeightEntryModel>> getAllWeightEntries() async {
    final userId = _currentUserService.getUserId();
    return await _weightLogRepository.getWeightEntriesForUser(userId);
  }
}
