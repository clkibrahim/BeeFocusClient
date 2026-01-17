import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'token_store.dart';
import 'auth_api.dart';

/// 401 hatası aldığında otomatik token refresh yapan interceptor
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.tokenStore,
    required this.authApi,
  });

  final Dio dio;
  final TokenStore tokenStore;
  final AuthApi authApi;
  
  bool _isRefreshing = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 Unauthorized hatası aldığımızda token'ı yenilemeye çalış
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      debugPrint('🔄 Token expired, attempting refresh...');
      
      try {
        final refreshToken = await tokenStore.getRefreshToken();
        
        if (refreshToken == null || refreshToken.isEmpty) {
          debugPrint('❌ No refresh token available, user needs to login again');
          _isRefreshing = false;
          return handler.next(err);
        }
        
        // Token'ı yenile
        final response = await authApi.refresh(refreshToken: refreshToken);
        
        final newAccessToken = response['accessToken'] ?? response['token'];
        final newRefreshToken = response['refreshToken'] ?? refreshToken;
        
        if (newAccessToken != null) {
          // Yeni token'ları kaydet
          final userId = await tokenStore.getUserId();
          final email = await tokenStore.getUserEmail();
          
          await tokenStore.setTokens(
            accessToken: newAccessToken.toString(),
            refreshToken: newRefreshToken.toString(),
            userId: userId,
            email: email,
          );
          
          debugPrint('✅ Token refreshed successfully');
          
          // Orijinal isteği yeni token ile tekrar dene
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';
          
          final retryResponse = await dio.fetch(opts);
          _isRefreshing = false;
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        debugPrint('❌ Token refresh failed: $e');
        // Refresh başarısız, kullanıcının tekrar giriş yapması gerekiyor
        await tokenStore.clearTokens();
      }
      
      _isRefreshing = false;
    }
    
    return handler.next(err);
  }
}
