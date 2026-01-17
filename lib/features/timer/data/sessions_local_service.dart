import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../core/local_db/local_db_service.dart';
import 'session_model.dart';

class SessionsLocalService {
  final LocalDbService _localDbService;

  SessionsLocalService(this._localDbService);

  Future<int> createSession(Session session) async {
    final isar = await _localDbService.db;
    final id = await isar.writeTxn(() async {
      return await isar.sessions.put(session);
    });
    debugPrint('💾 Session saved locally: id=$id, subject=${session.subjectRemoteId}, synced=${session.isSynced}');
    return id;
  }

  Future<void> updateSession(Session session) async {
    final isar = await _localDbService.db;
    await isar.writeTxn(() async {
      await isar.sessions.put(session);
    });
    debugPrint('💾 Session updated: id=${session.id}, synced=${session.isSynced}');
  }

  Future<Session?> getSession(int id) async {
    final isar = await _localDbService.db;
    return await isar.sessions.get(id);
  }

  Future<List<Session>> getUnsyncedCompletedSessions() async {
    final isar = await _localDbService.db;
    return await isar.sessions
        .filter()
        .isSyncedEqualTo(false)
        .statusEqualTo(SessionStatus.completed)
        .findAll();
  }
  
  Future<List<Session>> getUnsyncedOngoingSessions() async {
    final isar = await _localDbService.db;
    return await isar.sessions
        .filter()
        .isSyncedEqualTo(false)
        .statusEqualTo(SessionStatus.ongoing)
        .findAll();
  }

  /// Tüm tamamlanmış session'ları getirir
  Future<List<Session>> getAllCompletedSessions() async {
    final isar = await _localDbService.db;
    return await isar.sessions
        .filter()
        .statusEqualTo(SessionStatus.completed)
        .findAll();
  }

  /// Belirli bir tarih aralığındaki tamamlanmış session'ları getirir
  Future<List<Session>> getSessionsInRange(DateTime start, DateTime end) async {
    final isar = await _localDbService.db;
    return await isar.sessions
        .filter()
        .statusEqualTo(SessionStatus.completed)
        .startedAtBetween(start, end)
        .findAll();
  }

  /// Belirli bir derse ait tamamlanmış session'ları getirir
  Future<List<Session>> getSessionsBySubject(String subjectRemoteId) async {
    final isar = await _localDbService.db;
    return await isar.sessions
        .filter()
        .statusEqualTo(SessionStatus.completed)
        .subjectRemoteIdEqualTo(subjectRemoteId)
        .findAll();
  }

  /// Tüm session'ları getirir (debug için)
  Future<List<Session>> getAllSessions() async {
    final isar = await _localDbService.db;
    return await isar.sessions.where().findAll();
  }

  /// Debug: Tüm session'ları logla
  Future<void> debugPrintAllSessions() async {
    final sessions = await getAllSessions();
    debugPrint('═══════════════════════════════════════════');
    debugPrint('📊 LOCAL DB SESSION DUMP (${sessions.length} total)');
    debugPrint('═══════════════════════════════════════════');
    for (final s in sessions) {
      debugPrint('  ID: ${s.id}');
      debugPrint('  Subject: ${s.subjectRemoteId}');
      debugPrint('  Started: ${s.startedAt}');
      debugPrint('  Ended: ${s.endedAt}');
      debugPrint('  Seconds: ${s.totalSeconds}');
      debugPrint('  Status: ${s.status}');
      debugPrint('  Synced: ${s.isSynced}');
      debugPrint('  ───────────────────────────────────────');
    }
    debugPrint('═══════════════════════════════════════════');
  }
}
