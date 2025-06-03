class UserModel {
  final int id;
  final String username;
  final String role;
  final String name;
  final String? avatar;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.name,
    this.avatar,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      name: json['name'],
      avatar: json['avatar'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'name': name,
      'avatar': avatar,
      'is_active': isActive,
    };
  }
} 