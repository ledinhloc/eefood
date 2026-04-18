import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

@JsonEnum(valueField: 'value')
enum PollStatus {
  @JsonValue('DRAFT')
  draft,

  @JsonValue('OPEN')
  open,

  @JsonValue('CLOSED')
  closed,
}

extension PollStatusX on PollStatus {
  String get text {
    switch (this) {
      case PollStatus.open:
        return 'Đang mở';
      case PollStatus.closed:
        return 'Đã đóng';
      case PollStatus.draft:
        return 'Chưa mở';
    }
  }

  Color get color {
    switch (this) {
      case PollStatus.open:
        return const Color(0xFF68D391);
      case PollStatus.closed:
        return const Color(0xFFFF8A80);
      case PollStatus.draft:
        return const Color(0xFFFFB067);
    }
  }
}
