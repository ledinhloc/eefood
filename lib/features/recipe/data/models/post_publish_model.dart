import 'package:json_annotation/json_annotation.dart';
part 'post_publish_model.g.dart';
enum PostStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('APPROVED')
  approved,

  @JsonValue('REJECTED')
  rejected,
}

@JsonSerializable()
class PostPublishModel {
  final int id;
  final int recipeId;
  final int userId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime? createdAt;

  // Các thông tin hiển thị
  final String? difficulty;
  final String? location;
  final String? prepTime;
  final String? cookTime;
  final int? countReaction;
  final int? countComment;
  final PostStatus status;

  PostPublishModel({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.createdAt,
    this.difficulty,
    this.location,
    this.prepTime,
    this.cookTime,
    this.countReaction,
    this.countComment,
    required this.status
  });

  factory PostPublishModel.fromJson(Map<String, dynamic> json) =>
      _$PostPublishModelFromJson(json);
  Map<String, dynamic> toJson() => _$PostPublishModelToJson(this);
}