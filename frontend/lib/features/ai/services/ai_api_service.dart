import 'package:frontend/core/network/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AIApiService extends ApiClient {
  AIApiService(super._firebaseAuthService);

  Future<http.Response> detectProducts(XFile image) async {
    return postMultipart("/ai/detect", "image", image);
  }
}
