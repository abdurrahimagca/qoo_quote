// services/base_api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class BaseApiService {
  final Dio _dio = Dio();
  final String? _baseUrl = dotenv.env["API_BASE_URL"];
  final String? _apiKey = dotenv.env["API_KEY"];
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Response> getRequest(String endpoint) async {
    final url = '$_baseUrl$endpoint';
    final headers = await _defaultHeaders();
    final response = await _dio.get(url, options: Options(headers: headers));
    _handleErrors(response);
    return response;
  }

  Future<Response> postRequest(String endpoint, dynamic data) async {
    final url = '$_baseUrl$endpoint';
    final headers = await _defaultHeaders();
    final response =
        await _dio.post(url, data: data, options: Options(headers: headers));
    _handleErrors(response);
    return response;
  }

  Future<Map<String, String>> _defaultHeaders() async {
    final token = await _storage.read(key: 'access-token');
    if (_apiKey == null) {
      throw Exception("API key is missing");
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'qq-api-key': _apiKey!,
    };
  }

  void _handleErrors(Response response) {
    if (response.statusCode != null && response.statusCode! >= 400) {
      throw Exception('Error ${response.statusCode}: ${response.data}');
    }
  }
}
