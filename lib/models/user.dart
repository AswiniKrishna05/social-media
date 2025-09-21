import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? profileImageUrl;

  @HiveField(4)
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    required this.createdAt,
  });

  // Factory constructor for creating a new user
  factory User.create({
    required String username,
    required String email,
    String? profileImageUrl,
  }) {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      email: email,
      profileImageUrl: profileImageUrl,
      createdAt: DateTime.now(),
    );
  }

  // Copy with method for updating user data
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, profileImageUrl: $profileImageUrl, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
