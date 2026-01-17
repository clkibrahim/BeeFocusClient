import '../../subjects/data/subject_model.dart';

/// Haftalık rapor modeli
class WeeklyReport {
  final int totalSeconds;
  final int averageDailySeconds;
  final int longestSessionSeconds;
  final List<DailyStats> dailyStats;
  final List<SubjectStats> subjectStats;
  final double weeklyGoalHours;
  final double completedHours;

  const WeeklyReport({
    required this.totalSeconds,
    required this.averageDailySeconds,
    required this.longestSessionSeconds,
    required this.dailyStats,
    required this.subjectStats,
    required this.weeklyGoalHours,
    required this.completedHours,
  });

  /// Toplam çalışma süresini formatlanmış string olarak döndürür
  String get formattedTotal {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours}s ${minutes}d';
  }

  /// Ortalama günlük çalışma süresini formatlanmış string olarak döndürür
  String get formattedAverageDaily {
    final hours = averageDailySeconds ~/ 3600;
    final minutes = (averageDailySeconds % 3600) ~/ 60;
    return '${hours}s ${minutes}d';
  }

  /// En uzun seansı formatlanmış string olarak döndürür
  String get formattedLongestSession {
    final hours = longestSessionSeconds ~/ 3600;
    final minutes = (longestSessionSeconds % 3600) ~/ 60;
    return '${hours}s ${minutes}d';
  }

  /// Hedef ilerleme yüzdesi
  double get progressPercentage {
    if (weeklyGoalHours <= 0) return 0;
    return (completedHours / weeklyGoalHours).clamp(0.0, 1.0);
  }

  /// Boş rapor oluşturur
  factory WeeklyReport.empty() {
    return const WeeklyReport(
      totalSeconds: 0,
      averageDailySeconds: 0,
      longestSessionSeconds: 0,
      dailyStats: [],
      subjectStats: [],
      weeklyGoalHours: 15,
      completedHours: 0,
    );
  }
}

/// Günlük istatistikler
class DailyStats {
  final String dayLabel;
  final int totalSeconds;
  final DateTime date;

  const DailyStats({
    required this.dayLabel,
    required this.totalSeconds,
    required this.date,
  });

  /// Normalize edilmiş değer (0.0 - 1.0 arası, max 4 saat baz alınarak)
  double normalizedValue({int maxSeconds = 4 * 3600}) {
    return (totalSeconds / maxSeconds).clamp(0.0, 1.0);
  }
}

/// Ders bazında istatistikler
class SubjectStats {
  final Subject subject;
  final int totalSeconds;

  const SubjectStats({required this.subject, required this.totalSeconds});

  /// Formatlanmış süre
  String get formattedDuration {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours}s ${minutes}d';
  }
}

/// Genel özet modeli (tüm zamanlar)
class TotalSummary {
  final int totalSeconds;
  final int thisWeekSeconds;
  final int weekDifference;

  const TotalSummary({
    required this.totalSeconds,
    required this.thisWeekSeconds,
    required this.weekDifference,
  });

  /// Toplam süreyi formatlanmış string olarak döndürür
  String get formattedTotal {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours}s ${minutes}d';
  }

  /// Haftalık farkı formatlanmış string olarak döndürür
  String get formattedWeekDifference {
    final hours = weekDifference.abs() ~/ 3600;
    final prefix = weekDifference >= 0 ? '+' : '-';
    return '$prefix${hours}h';
  }

  factory TotalSummary.empty() {
    return const TotalSummary(
      totalSeconds: 0,
      thisWeekSeconds: 0,
      weekDifference: 0,
    );
  }
}
