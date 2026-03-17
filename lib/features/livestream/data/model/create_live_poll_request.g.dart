// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_live_poll_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateLivePollRequest _$CreateLivePollRequestFromJson(
        Map<String, dynamic> json) =>
    CreateLivePollRequest(
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      allowChangeVote: json['allowChangeVote'] as bool?,
      multipleChoice: json['multipleChoice'] as bool?,
      maxChoices: (json['maxChoices'] as num?)?.toInt(),
      resultVisibility: $enumDecodeNullable(
          _$PollResultVisibilityEnumMap, json['resultVisibility']),
      voterVisibility: $enumDecodeNullable(
          _$PollVoterVisibilityEnumMap, json['voterVisibility']),
      optionAddMode: $enumDecodeNullable(
          _$PollOptionAddModeEnumMap, json['optionAddMode']),
    );

Map<String, dynamic> _$CreateLivePollRequestToJson(
        CreateLivePollRequest instance) =>
    <String, dynamic>{
      'question': instance.question,
      'options': instance.options,
      'allowChangeVote': instance.allowChangeVote,
      'multipleChoice': instance.multipleChoice,
      'maxChoices': instance.maxChoices,
      'resultVisibility':
          _$PollResultVisibilityEnumMap[instance.resultVisibility],
      'voterVisibility': _$PollVoterVisibilityEnumMap[instance.voterVisibility],
      'optionAddMode': _$PollOptionAddModeEnumMap[instance.optionAddMode],
    };

const _$PollResultVisibilityEnumMap = {
  PollResultVisibility.always: 'ALWAYS',
  PollResultVisibility.afterVote: 'AFTER_VOTE',
  PollResultVisibility.afterClose: 'AFTER_CLOSE',
};

const _$PollVoterVisibilityEnumMap = {
  PollVoterVisibility.anonymous: 'ANONYMOUS',
  PollVoterVisibility.public: 'PUBLIC',
};

const _$PollOptionAddModeEnumMap = {
  PollOptionAddMode.hostOnly: 'HOST_ONLY',
  PollOptionAddMode.viewerWithApproval: 'VIEWER_WITH_APPROVAL',
  PollOptionAddMode.viewerFree: 'VIEWER_FREE',
};
