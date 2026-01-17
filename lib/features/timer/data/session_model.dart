import 'package:isar/isar.dart';

part 'session_model.g.dart';

@collection
class Session {
	Session({
		this.id = Isar.autoIncrement,
		required this.subjectRemoteId,
		required this.startedAt,
		this.endedAt,
		this.totalSeconds,
		this.status = SessionStatus.completed,
		this.isSynced = false,
	});

	Id id;

	/// Backend subject id (string olarak saklıyoruz)
	@Index()
	String subjectRemoteId;

	DateTime startedAt;
	DateTime? endedAt;

	/// Oturumun toplam süresi (saniye)
	int? totalSeconds;

	@enumerated
	SessionStatus status;

	@Index()
	bool isSynced;
}

enum SessionStatus { ongoing, completed }

