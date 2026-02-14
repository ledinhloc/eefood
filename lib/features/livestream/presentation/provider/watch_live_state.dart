import 'package:eefood/features/livestream/data/model/live_stream_response.dart';

class WatchLiveState {
  final bool loading;
  final LiveStreamResponse? stream;
  final String? error;
  final bool isStreamEnded;
  final String? streamEndMessage;

  WatchLiveState({
    this.loading = false,
    this.stream,
    this.error,
    this.isStreamEnded = false,
    this.streamEndMessage,
  });

  WatchLiveState copyWith({
    bool? loading,
    LiveStreamResponse? stream,
    String? error,
    bool? isStreamEnded,
    String? streamEndMessage,
  }) {
    return WatchLiveState(
      loading: loading ?? this.loading,
      stream: stream ?? this.stream,
      error: error,
      isStreamEnded: isStreamEnded ?? this.isStreamEnded,
      streamEndMessage: streamEndMessage,
    );
  }
}