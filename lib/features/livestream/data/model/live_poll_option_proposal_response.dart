import 'package:eefood/features/livestream/domain/enum/poll_option_proposal_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'live_poll_option_proposal_response.g.dart';

@JsonSerializable()
class LivePollOptionProposalResponse {
  final int id;
  final int pollId;
  final int proposedBy;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final String text;
  final PollOptionProposalStatus status;
  final DateTime? createdAt;

  LivePollOptionProposalResponse({
    required this.id,
    required this.pollId,
    required this.proposedBy,
    this.username,
    this.email,
    this.avatarUrl,
    required this.text,
    required this.status,
    this.createdAt,
  });

  factory LivePollOptionProposalResponse.fromJson(Map<String, dynamic> json) =>
      _$LivePollOptionProposalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LivePollOptionProposalResponseToJson(this);
}
