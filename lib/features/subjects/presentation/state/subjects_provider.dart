import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../timer/data/session_model.dart';
import '../../data/subject_model.dart';
import '../../data/subjects_api.dart';
import '../../data/subjects_local_service.dart';
import '../../../../core/local_db/local_db_service.dart';

final subjectsApiProvider = Provider<SubjectsApi>((ref) {
  return SubjectsApi();
});

final subjectsLocalServiceProvider = Provider<SubjectsLocalService>((ref) {
  return SubjectsLocalService(LocalDbService());
});

/// Offline-first subjects list:
/// - Önce backend'den çekmeyi dener ve başarılı olursa local Isar'a yazar.
/// - Backend hatasında Isar'daki son kayıtlı dersleri döner.
final subjectsProvider = FutureProvider.autoDispose<List<Subject>>((ref) async {
  final api = ref.watch(subjectsApiProvider);
  final local = ref.watch(subjectsLocalServiceProvider);

  try {
    final remoteSubjects = await api.fetchAll();
    // Local cache'i güncelle
    await local.putSubjects(remoteSubjects);
    return remoteSubjects;
  } catch (_) {
    // Ağ yoksa / backend hata verirse en son local cache'i kullan
    final cached = await local.getAllSubjects();
    if (cached.isNotEmpty) {
      return cached;
    }
    rethrow;
  }
});
