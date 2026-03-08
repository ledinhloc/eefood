// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_poll_setting_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LivePollSettingResponse _$LivePollSettingResponseFromJson(
        Map<String, dynamic> json) =>
    LivePollSettingResponse(
      allowChangeVote: json['allowChangeVote'] as bool,
      multipleChoice: json['multipleChoice'] as bool,
      maxChoices: (json['maxChoices'] as num).toInt(),
      resultVisibility:
          $enumDecode(_$PollResultVisibilityEnumMap, json['resultVisibility']),
      voterVisibility:
          $enumDecode(_$PollVoterVisibilityEnumMap, json['voterVisibility']),
      optionAddMode:
          $enumDecode(_$PollOptionAddModeEnumMap, json['optionAddMode']),
    );

Map<String, dynamic> _$LivePollSettingResponseToJson(
        LivePollSettingResponse instance) =>
    <String, dynamic>{
      'allowChangeVote': instance.allowChangeVote,
      'multipleChoice': instance.multipleChoice,
      'maxChoices': instance.maxChoices,
      'resultVisibility':
          _$PollResultVisibilityEnumMap[instance.resultVisibility]!,
      'voterVisibility':
          _$PollVoterVisibilityEnumMap[instance.voterVisibility]!,
      'optionAddMode': _$PollOptionAddModeEnumMap[instance.optionAddMode]!,
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
  PollOptionAddMode.modOnly: 'MOD_ONLY',
  PollOptionAddMode.viewerWithApproval: 'VIEWER_WITH_APPROVAL',
  PollOptionAddMode.viewerFree: 'VIEWER_FREE',
};
