class User {
  final int? id;
  final String email;
  final String passwordHash;
  final bool isAdmin;
  final DateTime joinedAt;

  User({
    this.id,
    required this.email,
    required this.passwordHash,
    this.isAdmin = false,
    required this.joinedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      passwordHash: json['password_hash'],
      isAdmin: json['isAdmin'] == 1 || json['isAdmin'] == true,
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'isAdmin': isAdmin ? 1 : 0,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}