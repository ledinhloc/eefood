// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_poll_option_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LivePollOptionResponse _$LivePollOptionResponseFromJson(
        Map<String, dynamic> json) =>
    LivePollOptionResponse(
      id: (json['id'] as num).toInt(),
      text: json['text'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$LivePollOptionResponseToJson(
        LivePollOptionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'count': instance.count,
    };
