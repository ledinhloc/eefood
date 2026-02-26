import 'package:json_annotation/json_annotation.dart';

part 'live_comment_response.g.dart';

@JsonSerializable()
class LiveCommentResponse {
  final int id;
  final int userId;
  final String username;
  final String? avatarUrl;
  final String message;
  final String createdAt;

  LiveCommentResponse({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.message,
    required this.createdAt,
  });

  factory LiveCommentResponse.fromJson(Map<String, dynamic> json)
  => _$LiveCommentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LiveCommentResponseToJson(this);
}
