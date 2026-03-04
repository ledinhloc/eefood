// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_comment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveCommentResponse _$LiveCommentResponseFromJson(Map<String, dynamic> json) =>
    LiveCommentResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      message: json['message'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$LiveCommentResponseToJson(
        LiveCommentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'message': instance.message,
      'createdAt': instance.createdAt,
    };
