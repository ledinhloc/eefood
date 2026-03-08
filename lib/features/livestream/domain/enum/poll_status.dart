import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PollStatus {
  @JsonValue('DRAFT')
  draft,

  @JsonValue('OPEN')
  open,

  @JsonValue('CLOSED')
  closed,
}