import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/subjects/data/subject_model.dart';
import '../../features/timer/data/session_model.dart';

class LocalDbService {
  late Future<Isar> db;

  LocalDbService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [SubjectSchema, SessionSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
