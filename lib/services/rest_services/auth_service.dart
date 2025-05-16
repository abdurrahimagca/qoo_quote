import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:qoo_quote/screens/login.dart';
import 'base_service.dart';

class AuthService extends BaseApiService {
  Future<Map<String, String>> refreshToken() async {
    const storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refresh-token');
    final response = await postRequest('/auth/refresh', {
      'refresh_token': refreshToken,
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

  static Future<void> logout(BuildContext context) async {
    const storage = FlutterSecureStorage();

    // Token'ları temizle
    await storage.deleteAll();

    // Uygulamayı baştan başlat
    if (context.mounted) {
      // Tüm route stack'i temizle ve login sayfasına yönlendir
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (route) => false,
      );

      // Alternatif olarak main sayfasına da yönlendirebilirsiniz
      // Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}
