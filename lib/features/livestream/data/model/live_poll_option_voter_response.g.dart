// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_poll_option_voter_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollOptionVoterResponse _$PollOptionVoterResponseFromJson(
        Map<String, dynamic> json) =>
    PollOptionVoterResponse(
      userId: (json['userId'] as num?)?.toInt(),
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      votedAt: json['votedAt'] == null
          ? null
          : DateTime.parse(json['votedAt'] as String),
    );

Map<String, dynamic> _$PollOptionVoterResponseToJson(
        PollOptionVoterResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'votedAt': instance.votedAt?.toIso8601String(),
    };
