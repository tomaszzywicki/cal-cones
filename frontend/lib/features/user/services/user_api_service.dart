import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/user/data/user_model.dart';
import 'package:frontend/features/user/data/user_onboarding_model.dart';
import 'package:frontend/features/user/data/user_update_model.dart';
import 'package:http/http.dart' as http;

class UserApiService extends ApiClient {
  UserApiService(super.firebaseAuthService);

  Future<http.Response> saveOnboardingInfo(UserOnboardingModel onboardingModel) async {
    return post('/user/onboarding/create/', onboardingModel.toJson());
  }

  Future<http.Response> updateUser(UserProfileModel userProfileModel) async {
    return post('/user/update/', userProfileModel.toJson());
  }
}
