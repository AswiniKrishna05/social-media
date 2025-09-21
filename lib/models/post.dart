import 'package:hive/hive.dart';
import 'user.dart';

part 'post.g.dart';

@HiveType(typeId: 1)
class Post extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String caption;

  @HiveField(3)
  final String? imageUrl;

  @HiveField(4)
  final int likesCount;

  @HiveField(5)
  final List<String> likedBy;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  // User information (not stored in Hive, populated from User model)
  User? user;

  Post({
    required this.id,
    required this.userId,
    required this.caption,
    this.imageUrl,
    this.likesCount = 0,
    this.likedBy = const [],
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  // Factory constructor for creating a new post
  factory Post.create({
    required String userId,
    required String caption,
    String? imageUrl,
  }) {
    final now = DateTime.now();
    return Post(
      id: now.millisecondsSinceEpoch.toString(),
      userId: userId,
      caption: caption,
      imageUrl: imageUrl,
      likesCount: 0,
      likedBy: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  // Copy with method for updating post data
  Post copyWith({
    String? id,
    String? userId,
    String? caption,
    String? imageUrl,
    int? likesCount,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  // Check if a user has liked this post
  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }

  // Toggle like for a user
  Post toggleLike(String userId) {
    List<String> newLikedBy = List.from(likedBy);
    int newLikesCount = likesCount;

    if (newLikedBy.contains(userId)) {
      newLikedBy.remove(userId);
      newLikesCount--;
    } else {
      newLikedBy.add(userId);
      newLikesCount++;
    }

    return copyWith(
      likedBy: newLikedBy,
      likesCount: newLikesCount,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Post{id: $id, userId: $userId, caption: $caption, imageUrl: $imageUrl, likesCount: $likesCount, likedBy: $likedBy, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
