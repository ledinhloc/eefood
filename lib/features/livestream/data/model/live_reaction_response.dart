import 'package:json_annotation/json_annotation.dart';
part 'live_reaction_response.g.dart';

@JsonSerializable()
class LiveReactionResponse {
  final int id;
  final int liveStreamId;
  final FoodEmotion emotion;
  final int userId;
  final String username;
  final String avatarUrl;
  final DateTime? createdAt;

  LiveReactionResponse({
    required this.id,
    required this.liveStreamId,
    required this.emotion,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    this.createdAt,
  });

  factory LiveReactionResponse.fromJson(Map<String, dynamic> json)
    => _$LiveReactionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LiveReactionResponseToJson(this);
}
enum FoodEmotion {
  DELICIOUS,
  LOVE_IT,
  DROOLING,
  BAD,
  NOT_GOOD,
}