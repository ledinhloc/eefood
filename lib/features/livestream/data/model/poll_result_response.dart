import 'package:json_annotation/json_annotation.dart';
import 'live_poll_option_response.dart';

part 'poll_result_response.g.dart';

@JsonSerializable()
class PollResultResponse {

  final int pollId;
  final List<LivePollOptionResponse> options;

  PollResultResponse({
    required this.pollId,
    required this.options,
  });

  factory PollResultResponse.fromJson(Map<String, dynamic> json)
      => _$PollResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PollResultResponseToJson(this);
}