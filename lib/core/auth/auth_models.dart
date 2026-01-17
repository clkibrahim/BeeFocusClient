class UserModel {
  final String id;
  final String email;
  final String? fullName;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
    );
  }

  /// Email'den kullanıcı adı çıkar (@ öncesi)
  String get displayName => fullName ?? email.split('@').first;

  /// İsmin baş harfi
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }
}
