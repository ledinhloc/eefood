import 'package:json_annotation/json_annotation.dart';

part 'live_poll_option_response.g.dart';

@JsonSerializable()
class LivePollOptionResponse {

  final int id;
  final String text;
  final int count;

  LivePollOptionResponse({
    required this.id,
    required this.text,
    required this.count,
  });

  factory LivePollOptionResponse.fromJson(Map<String, dynamic> json)
      => _$LivePollOptionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LivePollOptionResponseToJson(this);
}