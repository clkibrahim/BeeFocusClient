import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/dio_client.dart';

class AuthApi {
  AuthApi({Dio? dio}) : _dio = dio ?? createDio();

  final Dio _dio;

  /// Kullanıcı kaydı
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    debugPrint('📤 Register request: $email');
    final res = await _dio.post(
      '/api/auth/register',
      data: {
        'email': email,
        'password': password,
      },
    );
    debugPrint('📥 Register response: ${res.data}');
    return Map<String, dynamic>.from(res.data);
  }

  /// Kullanıcı girişi
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    debugPrint('📤 Login request: $email');
    final res = await _dio.post(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    debugPrint('📥 Login response: ${res.data}');
    return Map<String, dynamic>.from(res.data);
  }

  /// Token yenileme
  Future<Map<String, dynamic>> refresh({
    required String refreshToken,
  }) async {
    final res = await _dio.post(
      '/api/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );
    return Map<String, dynamic>.from(res.data);
  }

  /// Mevcut kullanıcı bilgisi
  Future<Map<String, dynamic>> getCurrentUser(String accessToken) async {
    final res = await _dio.get(
      '/api/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return Map<String, dynamic>.from(res.data);
  }
}
