import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/local_db/local_db_service.dart';
import '../../../timer/data/sessions_local_service.dart';
import '../../../subjects/data/subjects_local_service.dart';
import '../../data/reports_model.dart';
import '../../data/reports_service.dart';

/// Sessions Local Service provider
final _sessionsLocalServiceProvider = Provider<SessionsLocalService>((ref) {
  return SessionsLocalService(LocalDbService());
});

/// Subjects Local Service provider
final _subjectsLocalServiceProvider = Provider<SubjectsLocalService>((ref) {
  return SubjectsLocalService(LocalDbService());
});

/// Reports Service provider
final reportsServiceProvider = Provider<ReportsService>((ref) {
  return ReportsService(
    sessionsLocalService: ref.watch(_sessionsLocalServiceProvider),
    subjectsLocalService: ref.watch(_subjectsLocalServiceProvider),
  );
});

/// Haftalık rapor provider
final weeklyReportProvider = FutureProvider.autoDispose<WeeklyReport>((
  ref,
) async {
  final service = ref.watch(reportsServiceProvider);
  return service.getWeeklyReport();
});

/// Genel özet provider
final totalSummaryProvider = FutureProvider.autoDispose<TotalSummary>((
  ref,
) async {
  final service = ref.watch(reportsServiceProvider);
  return service.getTotalSummary();
});
