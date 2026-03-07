import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PollResultVisibility {
  @JsonValue('ALWAYS')
  always,

  @JsonValue('AFTER_VOTE')
  afterVote,

  @JsonValue('AFTER_CLOSE')
  afterClose,
}