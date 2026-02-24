// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_stream_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveStreamResponse _$LiveStreamResponseFromJson(Map<String, dynamic> json) =>
    LiveStreamResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      roomName: json['roomName'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      status: $enumDecode(_$LiveStreamStatusEnumMap, json['status']),
      viewerCount: (json['viewerCount'] as num).toInt(),
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      livekitToken: json['livekitToken'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$LiveStreamResponseToJson(LiveStreamResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'roomName': instance.roomName,
      'title': instance.title,
      'description': instance.description,
      'thumbnailUrl': instance.thumbnailUrl,
      'status': _$LiveStreamStatusEnumMap[instance.status]!,
      'viewerCount': instance.viewerCount,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'livekitToken': instance.livekitToken,
      'username': instance.username,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
    };

const _$LiveStreamStatusEnumMap = {
  LiveStreamStatus.SCHEDULED: 'SCHEDULED',
  LiveStreamStatus.LIVE: 'LIVE',
  LiveStreamStatus.ENDED: 'ENDED',
  LiveStreamStatus.CANCELLED: 'CANCELLED',
};
