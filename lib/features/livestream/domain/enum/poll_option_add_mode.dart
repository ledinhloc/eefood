import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PollOptionAddMode {
  @JsonValue('HOST_ONLY')
  hostOnly,

  @JsonValue('MOD_ONLY')
  modOnly,

  @JsonValue('VIEWER_WITH_APPROVAL')
  viewerWithApproval,

  @JsonValue('VIEWER_FREE')
  viewerFree,
}