import 'package:isar/isar.dart';
import '../../../core/local_db/local_db_service.dart';
import 'subject_model.dart';

class SubjectsLocalService {
  final LocalDbService _localDbService;

  SubjectsLocalService(this._localDbService);

  Future<List<Subject>> getAllSubjects() async {
    final isar = await _localDbService.db;
    return isar.subjects.where().findAll();
  }

  Future<void> putSubjects(List<Subject> subjects) async {
    final isar = await _localDbService.db;
    await isar.writeTxn(() async {
      for (var subject in subjects) {
        // remoteId'ye göre var olanı bulup ID'sini koruyoruz
        final existing = await isar.subjects.getByRemoteId(subject.remoteId);
        if (existing != null) {
          subject.id = existing.id;
        }
        await isar.subjects.put(subject);
      }
    });
  }

  Future<void> clearSubjects() async {
    final isar = await _localDbService.db;
    await isar.writeTxn(() async {
      await isar.subjects.clear();
    });
  }
}
