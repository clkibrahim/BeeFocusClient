import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/auth/token_store.dart';

class SessionsApi {
  SessionsApi({Dio? dio, required TokenStore tokenStore})
      : _dio = dio ?? createAuthDio(tokenStore),
        _tokenStore = tokenStore;

  final Dio _dio;
  final TokenStore _tokenStore;

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStore.getAccessToken();
    debugPrint('🔑 Token: ${token != null ? "exists" : "NULL"}');
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Session başlatır ve backend'den sessionId döner
  /// sessionType: 0 = Pomodoro, 1 = Stopwatch
  Future<String> startSession({
    required String subjectId,
    required DateTime startTime,
    required int sessionType,
    int? durationGoalMinutes,
  }) async {
    final userId = await _tokenStore.getUserId();
    debugPrint('👤 UserId: $userId');
    if (userId == null) throw Exception('User not logged in');

    final requestData = {
      'userId': userId,
      'subjectId': subjectId,
      'sessionType': sessionType,
      'startTime': startTime.toUtc().toIso8601String(),
      if (durationGoalMinutes != null) 'durationGoalMinutes': durationGoalMinutes,
    };
    debugPrint('📤 Starting session with data: $requestData');

    final res = await _dio.post(
      '/api/sessions/start',
      data: requestData,
      options: Options(headers: await _authHeaders()),
    );
    
    debugPrint('📥 Response: ${res.data}');
    
    // Backend'den dönen sessionId - plain string veya map olabilir
    final data = res.data;
    if (data is String) {
      return data;
    }
    if (data is Map && data.containsKey('sessionId')) {
      return data['sessionId'].toString();
    }
    if (data is Map && data.containsKey('id')) {
      return data['id'].toString();
    }
    throw Exception('Session ID not found in response: $data');
  }

  /// Session'ı bitirir
  Future<void> finishSession({
    required String sessionId,
    required DateTime endTime,
    int? totalSeconds,
    String? notes,
  }) async {
    final userId = await _tokenStore.getUserId();
    if (userId == null) throw Exception('User not logged in');

    final requestData = {
      'sessionId': sessionId,
      'userId': userId,
      'endTime': endTime.toUtc().toIso8601String(),
      if (totalSeconds != null) 'totalSeconds': totalSeconds,
      if (notes != null) 'notes': notes,
    };
    debugPrint('📤 Finishing session with data: $requestData');

    await _dio.post(
      '/api/sessions/$sessionId/finish',
      data: requestData,
      options: Options(headers: await _authHeaders()),
    );
    
    debugPrint('✅ Session finished on server: $sessionId');
  }

  /// Bugünkü session'ları getirir
  Future<List<Map<String, dynamic>>> fetchTodaySessions() async {
    final res = await _dio.get(
      '/api/sessions/today',
      options: Options(headers: await _authHeaders()),
    );
    if (res.data is List) {
      return (res.data as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    throw const FormatException('Sessions response is not a list');
  }

  /// Belirli bir session'ı getirir
  Future<Map<String, dynamic>> fetchSession(String sessionId) async {
    final res = await _dio.get(
      '/api/sessions/$sessionId',
      options: Options(headers: await _authHeaders()),
    );
    return Map<String, dynamic>.from(res.data);
  }

  /// Belirli bir subject'e ait session'ları getirir
  Future<List<Map<String, dynamic>>> fetchBySubject(String subjectId) async {
    final res = await _dio.get(
      '/api/sessions/subject/$subjectId',
      options: Options(headers: await _authHeaders()),
    );
    if (res.data is List) {
      return (res.data as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    throw const FormatException('Sessions response is not a list');
  }

  /// Belirli bir tarihteki session'ları getirir
  Future<List<Map<String, dynamic>>> fetchByDate(DateTime date) async {
    final res = await _dio.get(
      '/api/sessions/date/${date.toIso8601String()}',
      options: Options(headers: await _authHeaders()),
    );
    if (res.data is List) {
      return (res.data as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    throw const FormatException('Sessions response is not a list');
  }

  /// Session siler
  Future<void> deleteSession(String sessionId) async {
    await _dio.delete(
      '/api/sessions/$sessionId',
      options: Options(headers: await _authHeaders()),
    );
  }
}

