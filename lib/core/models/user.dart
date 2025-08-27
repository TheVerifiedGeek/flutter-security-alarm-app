class AppUser {
  final int? id;
  final String username;
  final String passwordHash; // store salted hash
  final String role; // admin, operator

  const AppUser({this.id, required this.username, required this.passwordHash, required this.role});

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'passwordHash': passwordHash,
    'role': role,
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'] as int?,
    username: m['username'] as String,
    passwordHash: m['passwordHash'] as String,
    role: m['role'] as String,
  );
}