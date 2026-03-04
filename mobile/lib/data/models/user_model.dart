class UserModel {
  final String id;
  final String phoneNumber;
  final String? name;
  final String role;
  final String? preferredLanguage;
  final String? fcmToken;
  final double? lat;
  final double? lng;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    required this.role,
    this.preferredLanguage,
    this.fcmToken,
    this.lat,
    this.lng,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      role: json['role'] ?? 'farmer',
      preferredLanguage: json['preferredLanguage'],
      fcmToken: json['fcmToken'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'role': role,
      'preferredLanguage': preferredLanguage,
      'fcmToken': fcmToken,
      'lat': lat,
      'lng': lng,
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? role,
    String? preferredLanguage,
    String? fcmToken,
    double? lat,
    double? lng,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      role: role ?? this.role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      fcmToken: fcmToken ?? this.fcmToken,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  /// Display name with fallback
  String get displayName => name ?? 'Farmer';

  /// Role label for UI
  String get roleLabel => role == 'admin' ? 'Admin' : 'Farmer';
}
