class UserEntity {
  final String userId;
  final String email;
  final String fullName;
  final String username;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  UserEntity({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.username,
    this.phone,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'technician',
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'username': username,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
