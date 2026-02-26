import 'package:eefood/features/chatbot/data/models/location_info_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chatbot_request.g.dart';

@JsonSerializable()
class ChatbotRequest {
  final String? chatRole;
  final String? message;
  final String? imageUrl;
  final LocationInfoRequest? location;
  final String? time;
  final List<int>? postId;
  final List<int>? recipeId;
  final int? userId;

  ChatbotRequest({
    this.chatRole,
    this.message,
    this.imageUrl,
    this.location,
    this.time,
    this.postId,
    this.recipeId,
    this.userId,
  });

  factory ChatbotRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatbotRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatbotRequestToJson(this);
}
