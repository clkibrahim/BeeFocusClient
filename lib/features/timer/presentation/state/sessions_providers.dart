import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/local_db/local_db_service.dart';
import '../../data/sessions_api.dart';
import '../../data/sessions_local_service.dart';
import '../../data/sessions_repository.dart';

/// Sessions API provider
final sessionsApiProvider = Provider<SessionsApi>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  return SessionsApi(tokenStore: tokenStore);
});

/// Sessions Local Service provider
final sessionsLocalServiceProvider = Provider<SessionsLocalService>((ref) {
  return SessionsLocalService(LocalDbService());
});

/// Sessions Repository provider
final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  return SessionsRepository(
    api: ref.watch(sessionsApiProvider),
    localService: ref.watch(sessionsLocalServiceProvider),
  );
});

/// Senkronizasyon durumu
final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

enum SyncStatus { idle, syncing, success, error }

/// Senkronize edilmemiş session'ları backend'e gönderir
/// Auth durumu değiştiğinde otomatik tetiklenir
final syncSessionsProvider = FutureProvider.autoDispose<void>((ref) async {
  // Auth durumunu dinle - giriş yapıldığında tetiklenecek
  final authState = ref.watch(authNotifierProvider);
  
  // Kullanıcı giriş yapmamışsa sync yapma
  final isLoggedIn = authState.valueOrNull ?? false;
  if (!isLoggedIn) {
    debugPrint('⏭️ Sync skipped - user not logged in');
    return;
  }
  
  final repository = ref.watch(sessionsRepositoryProvider);

  try {
    debugPrint('🔄 Starting session sync...');
    await repository.syncUnsyncedSessions();
    debugPrint('✅ Sessions synced successfully');
  } catch (e) {
    debugPrint('❌ Failed to sync sessions: $e');
    rethrow;
  }
});

/// Manuel senkronizasyon tetikleyici
final triggerSyncProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repository = ref.read(sessionsRepositoryProvider);
    await repository.syncUnsyncedSessions();
  };
});
