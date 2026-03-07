import 'package:eefood/features/livestream/data/model/live_poll_response.dart';
import 'package:eefood/features/livestream/data/model/poll_result_response.dart';

class LivePollState {
  final bool loading;
  final bool actionLoading;
  final bool socketConnected;
  final String? error;

  final int? liveStreamId;
  final LivePollResponse? poll;
  final PollResultResponse? result;

  final List<int> selectedOptionIds;

  const LivePollState({
    this.loading = false,
    this.actionLoading = false,
    this.socketConnected = false,
    this.error,
    this.liveStreamId,
    this.poll,
    this.result,
    this.selectedOptionIds = const [],
  });

  bool get hasPoll => poll != null;
  bool get hasResult => result != null;

  LivePollState copyWith({
    bool? loading,
    bool? actionLoading,
    bool? socketConnected,
    String? error,
    bool clearError = false,
    int? liveStreamId,
    LivePollResponse? poll,
    bool clearPoll = false,
    PollResultResponse? result,
    bool clearResult = false,
    List<int>? selectedOptionIds,
  }) {
    return LivePollState(
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      socketConnected: socketConnected ?? this.socketConnected,
      error: clearError ? null : (error ?? this.error),
      liveStreamId: liveStreamId ?? this.liveStreamId,
      poll: clearPoll ? null : (poll ?? this.poll),
      result: clearResult ? null : (result ?? this.result),
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
    );
  }
}
