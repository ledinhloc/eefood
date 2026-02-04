import 'package:equatable/equatable.dart';

import '../../data/model/live_comment_response.dart';

class StreamerCommentState extends Equatable {
  final List<LiveCommentResponse> comments;
  final int? liveStreamId;
  final String? error;
  final bool loading;

  const StreamerCommentState({
    this.comments = const [],
    this.liveStreamId,
    this.error,
    this.loading = false,
  });

  factory StreamerCommentState.initial() => const StreamerCommentState(
    loading: false,
    comments: [],
  );

  StreamerCommentState copyWith({
    List<LiveCommentResponse>? comments,
    int? liveStreamId,
    String? error,
    bool? loading,
  }) {
    return StreamerCommentState(
      comments: comments ?? this.comments,
      liveStreamId: liveStreamId ?? this.liveStreamId,
      error: error,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [comments, liveStreamId, error, loading];
}
