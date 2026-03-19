import 'package:eefood/features/livestream/data/model/live_poll_option_proposal_response.dart';
import 'package:equatable/equatable.dart';

class LivePollOptionProposalState extends Equatable {
  final int? liveStreamId;
  final int? pollId;
  final List<LivePollOptionProposalResponse> proposals;
  final LivePollOptionProposalResponse? latestProposal;
  final bool loading;
  final bool actionLoading;
  final String? error;

  const LivePollOptionProposalState({
    this.liveStreamId,
    this.pollId,
    this.proposals = const [],
    this.latestProposal,
    this.loading = false,
    this.actionLoading = false,
    this.error,
  });

  LivePollOptionProposalState copyWith({
    int? liveStreamId,
    int? pollId,
    List<LivePollOptionProposalResponse>? proposals,
    LivePollOptionProposalResponse? latestProposal,
    bool? loading,
    bool? actionLoading,
    String? error,
    bool clearError = false,
    bool clearLatestProposal = false,
    bool clearProposals = false,
  }) {
    return LivePollOptionProposalState(
      liveStreamId: liveStreamId ?? this.liveStreamId,
      pollId: pollId ?? this.pollId,
      proposals: clearProposals ? const [] : (proposals ?? this.proposals),
      latestProposal: clearLatestProposal
          ? null
          : (latestProposal ?? this.latestProposal),
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    liveStreamId,
    pollId,
    proposals,
    latestProposal,
    loading,
    actionLoading,
    error,
  ];
}
