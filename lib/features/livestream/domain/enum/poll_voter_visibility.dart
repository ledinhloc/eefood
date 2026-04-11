import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum PollVoterVisibility {
  @JsonValue('ANONYMOUS')
  anonymous,

  @JsonValue('PUBLIC')
  public,
}

extension PollVoterVisibilityX on PollVoterVisibility {
  String get text {
    switch (this) {
      case PollVoterVisibility.anonymous:
        return 'Ẩn danh';
      case PollVoterVisibility.public:
        return 'Công khai';
    }
  }
}
