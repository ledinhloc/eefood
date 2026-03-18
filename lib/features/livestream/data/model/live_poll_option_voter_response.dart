import 'package:json_annotation/json_annotation.dart';
part 'live_poll_option_voter_response.g.dart';

@JsonSerializable()
class PollOptionVoterResponse {
  final int? userId;
  final String? username;
  final String? avatarUrl;
  final DateTime? votedAt;

  PollOptionVoterResponse({
    this.userId,
    this.username,
    this.avatarUrl,
    this.votedAt,
  });

  factory PollOptionVoterResponse.fromJson(Map<String, dynamic> json) =>
      _$PollOptionVoterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PollOptionVoterResponseToJson(this);
}
