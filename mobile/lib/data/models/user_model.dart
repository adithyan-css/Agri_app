class UserModel {
  final String id;
  final String phoneNumber;
  final String? name;
  final String role;
  final String? preferredLanguage;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    required this.role,
    this.preferredLanguage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      role: json['role'] ?? 'farmer',
      preferredLanguage: json['preferredLanguage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'role': role,
      'preferredLanguage': preferredLanguage,
    };
  }
}
