import 'package:flutter/foundation.dart';
import 'session_model.dart';
import 'sessions_api.dart';
import 'sessions_local_service.dart';

class SessionsRepository {
  SessionsRepository({
    required SessionsApi api,
    required SessionsLocalService localService,
  })  : _api = api,
        _localService = localService;

  final SessionsApi _api;
  final SessionsLocalService _localService;

  /// Session başlatır - önce API'ye gönderir, sonra yerel veritabanına kaydeder
  /// Dönen değer: remote sessionId (backend'den gelen UUID)
  Future<String?> startSession({
    required String subjectId,
    required DateTime startTime,
    required int sessionType, // 0 = Pomodoro, 1 = Stopwatch
    int? durationGoalMinutes,
  }) async {
    String? remoteSessionId;
    
    try {
      // API'ye session başlatma isteği gönder
      remoteSessionId = await _api.startSession(
        subjectId: subjectId,
        startTime: startTime,
        sessionType: sessionType,
        durationGoalMinutes: durationGoalMinutes,
      );
      debugPrint('✅ Session started on server: $remoteSessionId');
    } catch (e) {
      // Kullanıcı giriş yapmamışsa veya ağ hatası varsa sessizce offline moda geç
      debugPrint('⚠️ Offline mode: Session will be saved locally. ($e)');
    }

    // Yerel veritabanına kaydet
    final localSession = Session(
      subjectRemoteId: subjectId,
      startedAt: startTime,
      status: SessionStatus.ongoing,
      isSynced: remoteSessionId != null,
    );
    await _localService.createSession(localSession);

    return remoteSessionId;
  }

  /// Session'ı bitirir - önce API'ye gönderir, sonra yerel veritabanını günceller
  Future<void> finishSession({
    required String? remoteSessionId,
    required String subjectId,
    required DateTime startTime,
    required DateTime endTime,
    required int totalSeconds,
    String? notes,
  }) async {
    bool synced = false;

    if (remoteSessionId != null) {
      try {
        await _api.finishSession(
          sessionId: remoteSessionId,
          endTime: endTime,
          totalSeconds: totalSeconds,
          notes: notes,
        );
        synced = true;
        debugPrint('✅ Session finished on server: $remoteSessionId');
      } catch (e) {
        debugPrint('⚠️ Failed to finish session on server, saved locally: $e');
      }
    } else {
      debugPrint('📱 Session saved locally (offline mode)');
    }

    // Yerel veritabanına tamamlanmış session olarak kaydet
    final localSession = Session(
      subjectRemoteId: subjectId,
      startedAt: startTime,
      endedAt: endTime,
      totalSeconds: totalSeconds,
      status: SessionStatus.completed,
      isSynced: synced,
    );
    await _localService.createSession(localSession);
  }

  /// Yerel veritabanındaki senkronize edilmemiş session'ları API'ye gönderir
  Future<void> syncUnsyncedSessions() async {
    final unsyncedSessions = await _localService.getUnsyncedCompletedSessions();
    
    if (unsyncedSessions.isEmpty) {
      debugPrint('📭 No unsynced sessions to sync');
      return;
    }
    
    debugPrint('📤 Syncing ${unsyncedSessions.length} unsynced sessions...');
    
    int successCount = 0;
    int failCount = 0;
    
    for (final session in unsyncedSessions) {
      try {
        debugPrint('🔄 Syncing session: id=${session.id}, subject=${session.subjectRemoteId}, start=${session.startedAt}, end=${session.endedAt}, seconds=${session.totalSeconds}');
        
        // Önce session başlat
        final remoteSessionId = await _api.startSession(
          subjectId: session.subjectRemoteId,
          startTime: session.startedAt,
          sessionType: 0, // Default pomodoro
        );
        
        // Sonra bitir
        if (session.endedAt != null) {
          await _api.finishSession(
            sessionId: remoteSessionId,
            endTime: session.endedAt!,
            totalSeconds: session.totalSeconds,
          );
        }
        
        // Başarılı sync, yerel kaydı güncelle
        session.isSynced = true;
        await _localService.updateSession(session);
        
        successCount++;
        debugPrint('✅ Session synced: ${session.id}');
      } catch (e) {
        failCount++;
        debugPrint('❌ Failed to sync session ${session.id}: $e');
        // Hata durumunda döngüye devam et, diğer session'ları da dene
      }
    }
    
    debugPrint('📊 Sync completed: $successCount success, $failCount failed');
  }
}
