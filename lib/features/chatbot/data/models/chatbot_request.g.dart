// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbot_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatbotRequest _$ChatbotRequestFromJson(Map<String, dynamic> json) =>
    ChatbotRequest(
      chatRole: json['chatRole'] as String?,
      message: json['message'] as String?,
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] == null
          ? null
          : LocationInfoRequest.fromJson(
              json['location'] as Map<String, dynamic>,
            ),
      time: json['time'] as String?,
      postId: (json['postId'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      recipeId: (json['recipeId'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      userId: (json['userId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChatbotRequestToJson(ChatbotRequest instance) =>
    <String, dynamic>{
      'chatRole': instance.chatRole,
      'message': instance.message,
      'imageUrl': instance.imageUrl,
      'location': instance.location,
      'time': instance.time,
      'postId': instance.postId,
      'recipeId': instance.recipeId,
      'userId': instance.userId,
    };
