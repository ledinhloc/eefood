import 'package:eefood/features/livestream/data/model/live_poll_option_proposal_response.dart';
import 'package:eefood/features/livestream/domain/enum/poll_option_proposal_status.dart';
import 'package:equatable/equatable.dart';

class LivePollOptionProposalState extends Equatable {
  final int? liveStreamId;
  final int? pollId;
  final List<LivePollOptionProposalResponse> proposals;
  final PollOptionProposalStatus? selectedStatus;
  final LivePollOptionProposalResponse? latestProposal;
  final bool loading;
  final bool actionLoading;
  final String? error;

  const LivePollOptionProposalState({
    this.liveStreamId,
    this.pollId,
    this.proposals = const [],
    this.selectedStatus = PollOptionProposalStatus.pending,
    this.latestProposal,
    this.loading = false,
    this.actionLoading = false,
    this.error,
  });

  LivePollOptionProposalState copyWith({
    int? liveStreamId,
    int? pollId,
    List<LivePollOptionProposalResponse>? proposals,
    PollOptionProposalStatus? selectedStatus,
    LivePollOptionProposalResponse? latestProposal,
    bool? loading,
    bool? actionLoading,
    String? error,
    bool clearError = false,
    bool clearLatestProposal = false,
    bool clearProposals = false,
    bool clearSelectedStatus = false,
  }) {
    return LivePollOptionProposalState(
      liveStreamId: liveStreamId ?? this.liveStreamId,
      pollId: pollId ?? this.pollId,
      proposals: clearProposals ? const [] : (proposals ?? this.proposals),
      selectedStatus: clearSelectedStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
      latestProposal: clearLatestProposal
          ? null
          : (latestProposal ?? this.latestProposal),
      loading: loading ?? this.loading,
      actionLoading: actionLoading ?? this.actionLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<LivePollOptionProposalResponse> get displayedProposals {
    if (selectedStatus == null) {
      return proposals;
    }

    return proposals.where((proposal) => proposal.status == selectedStatus).toList();
  }

  @override
  List<Object?> get props => [
    liveStreamId,
    pollId,
    proposals,
    selectedStatus,
    latestProposal,
    loading,
    actionLoading,
    error,
  ];
}
