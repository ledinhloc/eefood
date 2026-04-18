import 'package:flutter/material.dart';
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

extension PollOptionProposalStatusX on PollOptionProposalStatus {
  String get text {
    switch (this) {
      case PollOptionProposalStatus.pending:
        return 'Chờ duyệt';
      case PollOptionProposalStatus.approved:
        return 'Đã chấp nhận';
      case PollOptionProposalStatus.rejected:
        return 'Đã từ chối';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case PollOptionProposalStatus.pending:
        return Colors.orange.withValues(alpha: 0.22);
      case PollOptionProposalStatus.approved:
        return Colors.green.withValues(alpha: 0.22);
      case PollOptionProposalStatus.rejected:
        return Colors.red.withValues(alpha: 0.22);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case PollOptionProposalStatus.pending:
        return Colors.orange.shade200;
      case PollOptionProposalStatus.approved:
        return Colors.green.shade200;
      case PollOptionProposalStatus.rejected:
        return Colors.red.shade200;
    }
  }
}
