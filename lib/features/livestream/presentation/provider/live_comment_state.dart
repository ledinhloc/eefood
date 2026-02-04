
import 'package:equatable/equatable.dart';

import '../../data/model/live_comment_response.dart';

class LiveCommentState extends Equatable{
  final bool loading;
  final List<LiveCommentResponse> comments;
  final int? liveStreamId;
  final String? error;

  const LiveCommentState({
    required this.loading,
    required this.comments,
    this.liveStreamId,
    this.error,
  });

  factory LiveCommentState.initial() =>
      const LiveCommentState(loading: false, comments: []);

  LiveCommentState copyWith({
    bool? loading,
    List<LiveCommentResponse>? comments,
    int? liveStreamId,
    String? error,
  }) {
    return LiveCommentState(
      loading: loading ?? this.loading,
      comments: comments ?? this.comments,
      liveStreamId: liveStreamId ?? this.liveStreamId,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, comments, liveStreamId, error];
}