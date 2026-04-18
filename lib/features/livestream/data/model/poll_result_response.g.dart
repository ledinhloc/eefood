// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_result_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollResultResponse _$PollResultResponseFromJson(Map<String, dynamic> json) =>
    PollResultResponse(
      pollId: (json['pollId'] as num).toInt(),
      options: (json['options'] as List<dynamic>)
          .map(
              (e) => LivePollOptionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PollResultResponseToJson(PollResultResponse instance) =>
    <String, dynamic>{
      'pollId': instance.pollId,
      'options': instance.options,
    };
