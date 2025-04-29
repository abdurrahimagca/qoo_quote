import 'base_service.dart';

class AuthService extends BaseApiService {
  Future<Map<String, String>> exchangeToken(String authCode) async {
    final response = await postRequest('/auth/exchange', {
      'auth_code': authCode,
    });

    final data = response.data;
    final access = data["accessToken"]?.toString();
    final refresh = data["refreshToken"]?.toString();

    if (access == null || refresh == null) {
      throw Exception("Token data is missing from response");
    }

    return {
      'accessToken': access,
      'refreshToken': refresh,
    };
  }

}
