import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PollOptionProposalStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('APPROVED')
  approved,

  @JsonValue('REJECTED')
  rejected,
}
