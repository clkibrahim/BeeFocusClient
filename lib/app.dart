import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/auth/auth_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/timer/presentation/state/sessions_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Uygulama açıldığında senkronizasyonu tetikle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSessions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama ön plana geldiğinde senkronizasyonu tetikle
    if (state == AppLifecycleState.resumed) {
      _syncSessions();
    }
  }

  Future<void> _syncSessions() async {
    try {
      // Önce kullanıcının giriş yapmış olduğunu kontrol et
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState.valueOrNull ?? false;
      
      if (!isLoggedIn) {
        debugPrint('⏭️ Sync skipped at startup - user not logged in');
        return;
      }
      
      final repository = ref.read(sessionsRepositoryProvider);
      await repository.syncUnsyncedSessions();
      debugPrint('✅ Startup sync completed');
    } catch (e) {
      debugPrint('❌ Startup sync error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BeeFocus',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
