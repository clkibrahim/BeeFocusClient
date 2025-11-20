class Subject {
  Subject({
    required this.id,
    required this.name,
    this.category,
    this.fields = const [],
    this.colorHex,
  });

  final String id;
  final String name;
  final int? category;
  final List<int> fields;
  final String? colorHex;

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: (json['id'] ?? '').toString(),
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
