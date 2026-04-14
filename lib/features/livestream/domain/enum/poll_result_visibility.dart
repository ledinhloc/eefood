import 'package:json_annotation/json_annotation.dart';

import 'poll_status.dart';

@JsonEnum(valueField: 'value')
enum PollResultVisibility {
  @JsonValue('ALWAYS')
  always,

  @JsonValue('AFTER_VOTE')
  afterVote,

  @JsonValue('AFTER_CLOSE')
  afterClose,
}

extension PollResultVisibilityX on PollResultVisibility {
  String get text {
    switch (this) {
      case PollResultVisibility.always:
        return 'Luôn hiển thị';
      case PollResultVisibility.afterVote:
        return 'Hiển thị sau khi bình chọn';
      case PollResultVisibility.afterClose:
        return 'Hiển thị sau khi đóng poll';
    }
  }

  String visibilityMessage({
    required bool hasVoted,
    required PollStatus pollStatus,
  }) {
    switch (this) {
      case PollResultVisibility.always:
        return 'Kết quả sẽ hiển thị tại đây.';
      case PollResultVisibility.afterVote:
        return hasVoted
            ? 'Kết quả đang được cập nhật.'
            : 'Bạn cần bình chọn trước khi xem kết quả.';
      case PollResultVisibility.afterClose:
        return pollStatus == PollStatus.closed
            ? 'Kết quả đang được cập nhật.'
            : 'Kết quả sẽ hiện khi poll đóng.';
    }
  }
}
