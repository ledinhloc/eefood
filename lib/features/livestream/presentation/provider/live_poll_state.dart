import 'package:equatable/equatable.dart';
import 'package:eefood/features/livestream/data/model/live_poll_option_voters_response.dart';
import 'package:eefood/features/livestream/data/model/live_poll_response.dart';
import 'package:eefood/features/livestream/data/model/poll_result_response.dart';

class LivePollState extends Equatable {
  final int? liveStreamId;
  final LivePollResponse? poll;
  final PollResultResponse? result;
  final PollOptionVotersResponse? optionVoters;

  final bool loading;
  final bool actionLoading;
  final bool socketConnected;
  final bool optionVotersLoading;

  final List<int> selectedOptionIds;

  final bool hasVoted;
  final List<int> votedOptionIds;
  final bool isHost;

  final String? error;

  const LivePollState({
    this.liveStreamId,
    this.poll,
    this.result,
    this.optionVoters,
    this.loading = false,
    this.actionLoading = false,
    this.socketConnected = false,
    this.optionVotersLoading = false,
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
    PollOptionVotersResponse? optionVoters,
    bool? loading,
    bool? actionLoading,
    bool? socketConnected,
    bool? optionVotersLoading,
    List<int>? selectedOptionIds,
    bool? hasVoted,
    List<int>? votedOptionIds,
    bool? isHost,
    String? error,
    bool clearError = false,
    bool clearPoll = false,
    bool clearResult = false,
    bool clearOptionVoters = false,
  }) {
    return LivePollState(
      liveStreamId: liveStreamId ?? this.liveStreamId,
      poll: clearPoll ? null : (poll ?? this.poll),
      result: clearResult ? null : (result ?? this.result),
      optionVoters:
          clearOptionVoters ? null : (optionVoters ?? this.optionVoters),
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      socketConnected: socketConnected ?? this.socketConnected,
      optionVotersLoading: optionVotersLoading ?? this.optionVotersLoading,
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
        optionVoters,
        loading,
        actionLoading,
        socketConnected,
        optionVotersLoading,
        selectedOptionIds,
        hasVoted,
        votedOptionIds,
        isHost,
        error,
      ];
}
