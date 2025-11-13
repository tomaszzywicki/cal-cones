import 'package:frontend/features/auth/data/user_auth_model.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/network/api_client.dart';

class AuthApiService extends ApiClient {
  AuthApiService(super.firebaseAuthService);

  Future<http.Response> signUp(UserAuthModel userAuthModel) {
    return post('/auth/signup/', userAuthModel.toJson());
  }

  Future<http.Response> signIn(UserAuthModel userAuthModel) {
    return post('/auth/signin/', userAuthModel.toJson());
  }

  Future<http.Response> deleteAccount() {
    // TODO
    throw UnimplementedError();
  }
}
