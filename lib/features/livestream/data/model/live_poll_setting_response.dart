import 'package:eefood/features/livestream/domain/enum/poll_option_add_mode.dart';
import 'package:eefood/features/livestream/domain/enum/poll_result_visibility.dart';
import 'package:eefood/features/livestream/domain/enum/poll_voter_visibility.dart';
import 'package:json_annotation/json_annotation.dart';

part 'live_poll_setting_response.g.dart';

@JsonSerializable()
class LivePollSettingResponse {

  final bool allowChangeVote;
  final bool multipleChoice;
  final int maxChoices;
  final PollResultVisibility resultVisibility;
  final PollVoterVisibility voterVisibility;
  final PollOptionAddMode optionAddMode;

  LivePollSettingResponse({
    required this.allowChangeVote,
    required this.multipleChoice,
    required this.maxChoices,
    required this.resultVisibility,
    required this.voterVisibility,
    required this.optionAddMode,
  });

  factory LivePollSettingResponse.fromJson(Map<String, dynamic> json)
      => _$LivePollSettingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LivePollSettingResponseToJson(this);
}