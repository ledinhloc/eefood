import 'package:eefood/features/livestream/data/model/live_poll_option_voter_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'live_poll_option_voter_response.dart';

part 'live_poll_option_voters_response.g.dart';

@JsonSerializable()
class PollOptionVotersResponse {
  final int? optionId;
  final String? optionText;
  final int? voteCount;
  final List<PollOptionVoterResponse>? voters;

  PollOptionVotersResponse({
    this.optionId,
    this.optionText,
    this.voteCount,
    this.voters,
  });

  factory PollOptionVotersResponse.fromJson(Map<String, dynamic> json) =>
      _$PollOptionVotersResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PollOptionVotersResponseToJson(this);
}