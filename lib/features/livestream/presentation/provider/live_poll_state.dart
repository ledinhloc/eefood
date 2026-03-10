import 'package:equatable/equatable.dart';
import 'package:eefood/features/livestream/data/model/live_poll_response.dart';
import 'package:eefood/features/livestream/data/model/poll_result_response.dart';

class LivePollState extends Equatable {
  final int? liveStreamId;
  final LivePollResponse? poll;
  final PollResultResponse? result;

  final bool loading;
  final bool actionLoading;
  final bool socketConnected;

  final List<int> selectedOptionIds;

  final bool hasVoted;
  final List<int> votedOptionIds;
  final bool isHost;

  final String? error;

  const LivePollState({
    this.liveStreamId,
    this.poll,
    this.result,
    this.loading = false,
    this.actionLoading = false,
    this.socketConnected = false,
    this.selectedOptionIds = const [],
    this.hasVoted = false,
    this.votedOptionIds = const [],
    this.isHost = false,
    this.error,
  });

  LivePollState copyWith({
    int? liveStreamId,
    LivePollResponse? poll,
    PollResultResponse? result,
    bool? loading,
    bool? actionLoading,
    bool? socketConnected,
    List<int>? selectedOptionIds,
    bool? hasVoted,
    List<int>? votedOptionIds,
    bool? isHost,
    String? error,
    bool clearError = false,
    bool clearPoll = false,
    bool clearResult = false,
  }) {
    return LivePollState(
      liveStreamId: liveStreamId ?? this.liveStreamId,
      poll: clearPoll ? null : (poll ?? this.poll),
      result: clearResult ? null : (result ?? this.result),
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      socketConnected: socketConnected ?? this.socketConnected,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      hasVoted: hasVoted ?? this.hasVoted,
      votedOptionIds: votedOptionIds ?? this.votedOptionIds,
      isHost: isHost ?? this.isHost,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        liveStreamId,
        poll,
        result,
        loading,
        actionLoading,
        socketConnected,
        selectedOptionIds,
        hasVoted,
        votedOptionIds,
        isHost,
        error,
      ];
}