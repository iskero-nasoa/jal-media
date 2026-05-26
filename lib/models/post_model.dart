import 'user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String? imageUrl;
  final String? caption;
  final DateTime createdAt;
  final UserModel? author;
  int likesCount;
  int commentsCount;
  bool isLiked;

  PostModel({
    required this.id,
    required this.userId,
    this.imageUrl,
    this.caption,
    required this.createdAt,
    this.author,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String?,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: json['users'] != null
          ? UserModel.fromJson(json['users'] as Map<String, dynamic>)
          : null,
      likesCount: (json['likes_count'] as int?) ?? 0,
      commentsCount: (json['comments_count'] as int?) ?? 0,
    );
  }
}
