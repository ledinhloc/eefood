import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PollOptionAddMode {
  @JsonValue('HOST_ONLY')
  hostOnly,

  @JsonValue('VIEWER_WITH_APPROVAL')
  viewerWithApproval,

  @JsonValue('VIEWER_FREE')
  viewerFree,
}

extension PollOptionAddModeX on PollOptionAddMode {
  String get text {
    switch (this) {
      case PollOptionAddMode.hostOnly:
        return 'Chỉ host được thêm đáp án';
      case PollOptionAddMode.viewerWithApproval:
        return 'Viewer đề xuất, host duyệt';
      case PollOptionAddMode.viewerFree:
        return 'Viewer được thêm tự do';
    }
  }
}
