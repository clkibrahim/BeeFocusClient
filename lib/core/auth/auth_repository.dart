import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'auth_api.dart';
import 'token_store.dart';

class AuthRepository {
  AuthRepository({
    AuthApi? api,
    TokenStore? tokenStore,
  })  : _api = api ?? AuthApi(),
        _tokenStore = tokenStore ?? TokenStore();

  final AuthApi _api;
  final TokenStore _tokenStore;

  /// JWT token'dan userId (sub claim) çıkarır
  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      // Base64 padding düzeltmesi
      String payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> data = jsonDecode(decoded);
      
      // "sub" claim'i userId'yi içerir
      return data['sub']?.toString();
    } catch (e) {
      debugPrint('❌ Failed to decode JWT: $e');
      return null;
    }
  }

  /// Kullanıcı kaydı ve otomatik giriş
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      await _api.register(email: email, password: password);
      // Kayıt başarılı, otomatik giriş yap
      return await login(email: email, password: password);
    } catch (e) {
      debugPrint('❌ Register failed: $e');
      rethrow;
    }
  }

  /// Kullanıcı girişi
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.login(email: email, password: password);
      
      final accessToken = response['accessToken'] ?? response['token'];
      final refreshToken = response['refreshToken'];
      
      if (accessToken == null) {
        throw Exception('Access token not found in response');
      }
      
      // userId'yi response'dan veya token'dan al
      String? userId = response['userId']?.toString() ?? response['id']?.toString();
      if (userId == null) {
        userId = _extractUserIdFromToken(accessToken.toString());
      }
      
      await _tokenStore.setTokens(
        accessToken: accessToken.toString(),
        refreshToken: refreshToken?.toString() ?? '',
        userId: userId,
        email: email,
      );
      
      debugPrint('✅ Login successful, userId: $userId');
      return true;
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      rethrow;
    }
  }

  /// Çıkış yap
  Future<void> logout() async {
    await _tokenStore.clearTokens();
    debugPrint('👋 Logged out');
  }

  /// Giriş yapılmış mı?
  Future<bool> isLoggedIn() async {
    return await _tokenStore.hasTokens();
  }

  /// Mevcut kullanıcı ID'si
  Future<String?> getCurrentUserId() async {
    return await _tokenStore.getUserId();
  }

  /// Mevcut kullanıcı email'i
  Future<String?> getCurrentUserEmail() async {
    return await _tokenStore.getUserEmail();
  }
}
