// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_poll_option_proposal_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LivePollOptionProposalResponse _$LivePollOptionProposalResponseFromJson(
        Map<String, dynamic> json) =>
    LivePollOptionProposalResponse(
      id: (json['id'] as num).toInt(),
      pollId: (json['pollId'] as num).toInt(),
      proposedBy: (json['proposedBy'] as num).toInt(),
      username: json['username'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      text: json['text'] as String,
      status: $enumDecode(_$PollOptionProposalStatusEnumMap, json['status']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LivePollOptionProposalResponseToJson(
        LivePollOptionProposalResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pollId': instance.pollId,
      'proposedBy': instance.proposedBy,
      'username': instance.username,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'text': instance.text,
      'status': _$PollOptionProposalStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$PollOptionProposalStatusEnumMap = {
  PollOptionProposalStatus.pending: 'PENDING',
  PollOptionProposalStatus.approved: 'APPROVED',
  PollOptionProposalStatus.rejected: 'REJECTED',
};
