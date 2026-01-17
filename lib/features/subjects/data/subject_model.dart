import 'package:isar/isar.dart';

part 'subject_model.g.dart';

@collection
class Subject {
  Subject({
    this.id = Isar.autoIncrement,
    required this.remoteId,
    required this.name,
    this.category,
    this.fields = const [],
    this.colorHex,
  });

  Id id;

  @Index(unique: true, replace: true)
  final String? remoteId;

  final String name;
  final int? category;
  final List<int> fields;
  final String? colorHex;

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      remoteId: (json['id'] ?? '').toString(),
      name: json['name'] as String,
      category: _parseInt(json['category']),
      fields: _parseIntList(json['fields']),
      colorHex: json['colorHex']?.toString(),
    );
  }

  static int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static List<int> _parseIntList(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => _parseInt(e))
          .whereType<int>()
          .toList(growable: false);
    }
    return const [];
  }
}
