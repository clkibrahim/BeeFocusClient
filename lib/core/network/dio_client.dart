import 'package:dio/dio.dart';

// Varsayılan base URL; dart-define ile override edebilirsin:
// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5026
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.116.67.232:5000',
);

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 12),
    ),
  );
  dio.interceptors.add(
    LogInterceptor(
      requestBody: false,
      responseBody: false,
      requestHeader: false,
      responseHeader: false,
    ),
  );
  return dio;
}
