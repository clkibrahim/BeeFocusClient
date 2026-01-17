import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../auth/auth_api.dart';
import '../auth/auth_interceptor.dart';
import '../auth/token_store.dart';

// Varsayılan base URL; dart-define ile override edebilirsin:
// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:5000',
);

/// Basit Dio instance (auth gerektirmeyen istekler için)
Dio createDio() {
  debugPrint('🌐 Creating Dio with baseUrl: $apiBaseUrl');
  
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 12),
    ),
  );
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      logPrint: (obj) => debugPrint('📡 $obj'),
    ),
  );
  return dio;
}

/// Auth interceptor'lı Dio instance (token refresh destekli)
Dio createAuthDio(TokenStore tokenStore) {
  debugPrint('🌐 Creating Auth Dio with baseUrl: $apiBaseUrl');
  
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 12),
    ),
  );
  
  // Log interceptor
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      logPrint: (obj) => debugPrint('📡 $obj'),
    ),
  );
  
  // Auth interceptor (token refresh)
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      tokenStore: tokenStore,
      authApi: AuthApi(),
    ),
  );
  
  return dio;
}
