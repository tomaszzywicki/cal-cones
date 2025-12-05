import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/user/data/user_model.dart';
import 'package:frontend/features/user/data/user_onboarding_model.dart';
import 'package:frontend/features/user/services/user_api_service.dart';

class UserService {
  final UserApiService _userApiService;
  final CurrentUserService currentUserService;
  UserService(this._userApiService, this.currentUserService);

  Future<void> saveOnboardingInfo(UserOnboardingModel userOnboardingModel) async {
    final currentUser = currentUserService.currentUser;
    if (currentUser == null) {
      throw Exception("No current user found");
    }

    final originalData = _createBackup(currentUser);

    try {
      // 1. Save onboarding info to backend
      final response = await _userApiService.saveOnboardingInfo(userOnboardingModel);

      if (response.statusCode != 201) {
        AppLogger.error('API Error: ${response.statusCode}. ${response.body}');
        throw Exception('Failed to save onboarding info: ${response.statusCode}');
      }

      // 2. Update current user data locally after a backend success
      _updateUserData(currentUser, userOnboardingModel);
      await currentUserService.updateUser(currentUser);

      AppLogger.info("Onboarding info saved and user data updated locally.");
    } catch (e) {
      // Rollback user data in case of error
      _restoreBackup(currentUser, originalData);
      await currentUserService.updateUser(currentUser);

      AppLogger.error("Error saving onboarding info: $e");
      rethrow;
    }
  }

  Map<String, dynamic> _createBackup(UserModel user) {
    return {
      'username': user.username,
      'birthday': user.birthday,
      'sex': user.sex,
      'height': user.height,
      'dietType': user.dietType,
      'macroSplit': user.macroSplit,
      'activityLevel': user.activityLevel,
      'setupCompleted': user.setupCompleted,
    };
  }

  void _restoreBackup(UserModel user, Map<String, dynamic> backup) {
    user.username = backup['username'];
    user.birthday = backup['birthday'];
    user.sex = backup['sex'];
    user.height = backup['height'];
    user.dietType = backup['dietType'];
    user.macroSplit = backup['macroSplit'];
    user.activityLevel = backup['activityLevel'];
    user.setupCompleted = backup['setupCompleted'];
  }

  void _updateUserData(UserModel user, UserOnboardingModel onboardingModel) {
    user.username = onboardingModel.username;
    user.birthday = onboardingModel.birthday;
    user.sex = onboardingModel.sex.toUpperCase();
    user.height = onboardingModel.height;
    user.dietType = onboardingModel.dietType.toUpperCase();
    user.macroSplit = onboardingModel.macroSplit;
    user.activityLevel = onboardingModel.activityLevel.toUpperCase();
    user.setupCompleted = true;
  }
}
