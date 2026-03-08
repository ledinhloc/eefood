// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_poll_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LivePollResponse _$LivePollResponseFromJson(Map<String, dynamic> json) =>
    LivePollResponse(
      id: (json['id'] as num).toInt(),
      liveStreamId: (json['liveStreamId'] as num).toInt(),
      question: json['question'] as String,
      status: $enumDecode(_$PollStatusEnumMap, json['status']),
      openedAt: json['openedAt'] == null
          ? null
          : DateTime.parse(json['openedAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      setting: LivePollSettingResponse.fromJson(
          json['setting'] as Map<String, dynamic>),
      options: (json['options'] as List<dynamic>)
          .map(
              (e) => LivePollOptionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LivePollResponseToJson(LivePollResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'liveStreamId': instance.liveStreamId,
      'question': instance.question,
      'status': _$PollStatusEnumMap[instance.status]!,
      'openedAt': instance.openedAt?.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
      'setting': instance.setting,
      'options': instance.options,
    };

const _$PollStatusEnumMap = {
  PollStatus.draft: 'DRAFT',
  PollStatus.open: 'OPEN',
  PollStatus.closed: 'CLOSED',
};
