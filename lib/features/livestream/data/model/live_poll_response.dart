import 'package:json_annotation/json_annotation.dart';

import '../../domain/enum/poll_status.dart';
import 'live_poll_option_response.dart';
import 'live_poll_setting_response.dart';

part 'live_poll_response.g.dart';

@JsonSerializable()
class LivePollResponse {

  final String id;
  final int liveStreamId;
  final String question;
  final PollStatus status;

  final DateTime? openedAt;
  final DateTime? closedAt;

  final LivePollSettingResponse setting;
  final List<LivePollOptionResponse> options;

  LivePollResponse({
    required this.id,
    required this.liveStreamId,
    required this.question,
    required this.status,
    this.openedAt,
    this.closedAt,
    required this.setting,
    required this.options,
  });

  factory LivePollResponse.fromJson(Map<String, dynamic> json)
      => _$LivePollResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LivePollResponseToJson(this);
}