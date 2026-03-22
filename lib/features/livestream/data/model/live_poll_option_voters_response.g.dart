// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_poll_option_voters_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollOptionVotersResponse _$PollOptionVotersResponseFromJson(
        Map<String, dynamic> json) =>
    PollOptionVotersResponse(
      optionId: (json['optionId'] as num?)?.toInt(),
      optionText: json['optionText'] as String?,
      voteCount: (json['voteCount'] as num?)?.toInt(),
      voters: (json['voters'] as List<dynamic>?)
          ?.map((e) =>
              PollOptionVoterResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PollOptionVotersResponseToJson(
        PollOptionVotersResponse instance) =>
    <String, dynamic>{
      'optionId': instance.optionId,
      'optionText': instance.optionText,
      'voteCount': instance.voteCount,
      'voters': instance.voters,
    };
