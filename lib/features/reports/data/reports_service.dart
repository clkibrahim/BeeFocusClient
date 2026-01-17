import '../../timer/data/session_model.dart';
import '../../timer/data/sessions_local_service.dart';
import '../../subjects/data/subject_model.dart';
import '../../subjects/data/subjects_local_service.dart';
import 'reports_model.dart';

class ReportsService {
  final SessionsLocalService _sessionsLocalService;
  final SubjectsLocalService _subjectsLocalService;

  ReportsService({
    required SessionsLocalService sessionsLocalService,
    required SubjectsLocalService subjectsLocalService,
  }) : _sessionsLocalService = sessionsLocalService,
       _subjectsLocalService = subjectsLocalService;

  /// Haftalık rapor oluşturur
  Future<WeeklyReport> getWeeklyReport({double weeklyGoalHours = 15}) async {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final sessions = await _sessionsLocalService.getSessionsInRange(
      weekStart,
      weekEnd,
    );

    final subjects = await _subjectsLocalService.getAllSubjects();

    // Toplam süre
    int totalSeconds = 0;
    int longestSessionSeconds = 0;

    for (final session in sessions) {
      final duration = session.totalSeconds ?? 0;
      totalSeconds += duration;
      if (duration > longestSessionSeconds) {
        longestSessionSeconds = duration;
      }
    }

    // Günlük dağılım
    final dailyStats = _calculateDailyStats(sessions, weekStart);

    // Ortalama günlük süre (sadece geçmiş günler için)
    final daysElapsed = now.difference(weekStart).inDays + 1;
    final averageDailySeconds = daysElapsed > 0
        ? totalSeconds ~/ daysElapsed
        : 0;

    // Ders bazında istatistikler
    final subjectStats = _calculateSubjectStats(sessions, subjects);

    final completedHours = totalSeconds / 3600;

    return WeeklyReport(
      totalSeconds: totalSeconds,
      averageDailySeconds: averageDailySeconds,
      longestSessionSeconds: longestSessionSeconds,
      dailyStats: dailyStats,
      subjectStats: subjectStats,
      weeklyGoalHours: weeklyGoalHours,
      completedHours: completedHours,
    );
  }

  /// Genel özeti getirir
  Future<TotalSummary> getTotalSummary() async {
    final allSessions = await _sessionsLocalService.getAllCompletedSessions();

    int totalSeconds = 0;
    for (final session in allSessions) {
      totalSeconds += session.totalSeconds ?? 0;
    }

    final now = DateTime.now();
    final thisWeekStart = _getWeekStart(now);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    final thisWeekSessions = await _sessionsLocalService.getSessionsInRange(
      thisWeekStart,
      now,
    );

    final lastWeekSessions = await _sessionsLocalService.getSessionsInRange(
      lastWeekStart,
      thisWeekStart,
    );

    int thisWeekSeconds = 0;
    for (final session in thisWeekSessions) {
      thisWeekSeconds += session.totalSeconds ?? 0;
    }

    int lastWeekSeconds = 0;
    for (final session in lastWeekSessions) {
      lastWeekSeconds += session.totalSeconds ?? 0;
    }

    return TotalSummary(
      totalSeconds: totalSeconds,
      thisWeekSeconds: thisWeekSeconds,
      weekDifference: thisWeekSeconds - lastWeekSeconds,
    );
  }

  /// Haftanın başlangıç tarihini döndürür (Pazartesi)
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: weekday - 1));
  }

  /// Günlük istatistikleri hesaplar
  List<DailyStats> _calculateDailyStats(
    List<Session> sessions,
    DateTime weekStart,
  ) {
    final dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final stats = <DailyStats>[];

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      int dayTotal = 0;
      for (final session in sessions) {
        if (session.startedAt.isAfter(dayStart) &&
            session.startedAt.isBefore(dayEnd)) {
          dayTotal += session.totalSeconds ?? 0;
        }
      }

      stats.add(
        DailyStats(dayLabel: dayLabels[i], totalSeconds: dayTotal, date: date),
      );
    }

    return stats;
  }

  /// Ders bazında istatistikleri hesaplar
  List<SubjectStats> _calculateSubjectStats(
    List<Session> sessions,
    List<Subject> subjects,
  ) {
    final subjectDurations = <String, int>{};

    for (final session in sessions) {
      final subjectId = session.subjectRemoteId;
      final duration = session.totalSeconds ?? 0;
      subjectDurations[subjectId] =
          (subjectDurations[subjectId] ?? 0) + duration;
    }

    final stats = <SubjectStats>[];
    for (final entry in subjectDurations.entries) {
      final subject = subjects.firstWhere(
        (s) => s.remoteId == entry.key,
        orElse: () => Subject(remoteId: entry.key, name: 'Bilinmeyen Ders'),
      );
      stats.add(SubjectStats(subject: subject, totalSeconds: entry.value));
    }

    // En çok çalışılan dersten en az çalışılana sırala
    stats.sort((a, b) => b.totalSeconds.compareTo(a.totalSeconds));

    return stats;
  }
}
