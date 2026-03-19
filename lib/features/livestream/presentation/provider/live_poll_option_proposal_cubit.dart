import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/data/model/live_poll_option_proposal_response.dart';
import 'package:eefood/features/livestream/domain/enum/poll_option_proposal_status.dart';
import 'package:eefood/features/livestream/domain/repository/live_poll_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'live_poll_option_proposal_state.dart';

class LivePollOptionProposalCubit extends Cubit<LivePollOptionProposalState> {
  final LivePollRepository repo = getIt<LivePollRepository>();

  LivePollOptionProposalCubit() : super(const LivePollOptionProposalState());

  Future<void> loadOptionProposals({
    required int liveStreamId,
    required int pollId,
    PollOptionProposalStatus? status,
  }) async {
    emit(
      state.copyWith(
        liveStreamId: liveStreamId,
        pollId: pollId,
        loading: true,
        clearError: true,
      ),
    );

    try {
      final proposals = await repo.getOptionProposals(
        liveStreamId: liveStreamId,
        pollId: pollId,
        status: status,
      );

      emit(
        state.copyWith(loading: false, proposals: proposals, clearError: true),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> createOptionProposal({
    required int liveStreamId,
    required int pollId,
    required String req,
  }) async {
    emit(
      state.copyWith(
        liveStreamId: liveStreamId,
        pollId: pollId,
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      final proposal = await repo.createOptionProposal(
        liveStreamId: liveStreamId,
        pollId: pollId,
        req: req,
      );

      emit(
        state.copyWith(
          actionLoading: false,
          latestProposal: proposal,
          proposals: _upsertProposal(proposal),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: e.toString()));
    }
  }

  Future<void> updateOptionProposalStatus({
    required int liveStreamId,
    required int pollId,
    required int proposalId,
    required PollOptionProposalStatus status,
  }) async {
    emit(
      state.copyWith(
        liveStreamId: liveStreamId,
        pollId: pollId,
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      final proposal = await repo.updateOptionProposalStatus(
        liveStreamId: liveStreamId,
        pollId: pollId,
        proposalId: proposalId,
        status: status,
      );

      emit(
        state.copyWith(
          actionLoading: false,
          latestProposal: proposal,
          proposals: _upsertProposal(proposal),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: e.toString()));
    }
  }

  void clearLatestProposal() {
    emit(state.copyWith(clearLatestProposal: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void reset() {
    emit(const LivePollOptionProposalState());
  }

  List<LivePollOptionProposalResponse> _upsertProposal(
    LivePollOptionProposalResponse proposal,
  ) {
    final updated = state.proposals
        .where((item) => item.id != proposal.id)
        .toList();

    return [proposal, ...updated];
  }
}
