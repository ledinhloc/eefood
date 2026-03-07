import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PollVoterVisibility {
  @JsonValue('ANONYMOUS')
  anonymous,

  @JsonValue('PUBLIC')
  public,
}