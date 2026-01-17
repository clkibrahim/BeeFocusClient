import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_api.dart';
import 'auth_models.dart';
import 'auth_repository.dart';
import 'token_store.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

/// Auth durumu - giriş yapılmış mı?
final authStateProvider = FutureProvider<bool>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return await authRepo.isLoggedIn();
});

/// Mevcut kullanıcı bilgisi
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final isLoggedIn = await authRepo.isLoggedIn();
  
  if (!isLoggedIn) return null;
  
  final userId = await authRepo.getCurrentUserId();
  final email = await authRepo.getCurrentUserEmail();
  
  if (userId == null || email == null) return null;
  
  return UserModel(id: userId, email: email);
});

/// Auth state notifier - giriş/çıkış işlemleri
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  AuthNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _checkAuthStatus();
  }

  final AuthRepository _authRepository;

  Future<void> _checkAuthStatus() async {
    state = const AsyncValue.loading();
    final isLoggedIn = await _authRepository.isLoggedIn();
    
    // Token var ama userId yoksa, logout yap (eski/bozuk token)
    if (isLoggedIn) {
      final userId = await _authRepository.getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        await _authRepository.logout();
        state = const AsyncValue.data(false);
        return;
      }
    }
    
    state = AsyncValue.data(isLoggedIn);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.login(email: email, password: password);
      state = const AsyncValue.data(true);
      debugPrint('✅ Login successful - sync will be triggered automatically');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.register(email: email, password: password);
      state = const AsyncValue.data(true);
      debugPrint('✅ Register successful - sync will be triggered automatically');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AsyncValue.data(false);
  }
}
