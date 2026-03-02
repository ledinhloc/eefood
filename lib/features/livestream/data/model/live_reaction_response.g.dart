// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_reaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveReactionResponse _$LiveReactionResponseFromJson(
        Map<String, dynamic> json) =>
    LiveReactionResponse(
      id: (json['id'] as num).toInt(),
      liveStreamId: (json['liveStreamId'] as num).toInt(),
      emotion: $enumDecode(_$FoodEmotionEnumMap, json['emotion']),
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LiveReactionResponseToJson(
        LiveReactionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'liveStreamId': instance.liveStreamId,
      'emotion': _$FoodEmotionEnumMap[instance.emotion]!,
      'userId': instance.userId,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$FoodEmotionEnumMap = {
  FoodEmotion.DELICIOUS: 'DELICIOUS',
  FoodEmotion.LOVE_IT: 'LOVE_IT',
  FoodEmotion.DROOLING: 'DROOLING',
  FoodEmotion.BAD: 'BAD',
  FoodEmotion.NOT_GOOD: 'NOT_GOOD',
};
