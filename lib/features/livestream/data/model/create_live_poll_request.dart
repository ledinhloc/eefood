import 'package:json_annotation/json_annotation.dart';

import '../../domain/enum/poll_option_add_mode.dart';
import '../../domain/enum/poll_result_visibility.dart';
import '../../domain/enum/poll_voter_visibility.dart';

part 'create_live_poll_request.g.dart';

@JsonSerializable()
class CreateLivePollRequest {

  final String question;
  final List<String> options;

  final bool? allowChangeVote;
  final bool? multipleChoice;
  final int? maxChoices;

  final PollResultVisibility? resultVisibility;
  final PollVoterVisibility? voterVisibility;
  final PollOptionAddMode? optionAddMode;

  CreateLivePollRequest({
    required this.question,
    required this.options,
    this.allowChangeVote,
    this.multipleChoice,
    this.maxChoices,
    this.resultVisibility,
    this.voterVisibility,
    this.optionAddMode,
  });

  factory CreateLivePollRequest.fromJson(Map<String, dynamic> json)
      => _$CreateLivePollRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateLivePollRequestToJson(this);
}