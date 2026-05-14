library;

class AuthUser {
  final int id;
  final String name;
  final String email;
  final String? username;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.username,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
    };
  }
}
