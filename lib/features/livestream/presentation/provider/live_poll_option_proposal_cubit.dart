import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/data/model/live_poll_option_proposal_response.dart';
import 'package:eefood/features/livestream/domain/enum/poll_option_proposal_status.dart';
import 'package:eefood/features/livestream/domain/repository/live_poll_repository.dart';
import 'package:eefood/features/livestream/presentation/provider/livestream_websocket_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'live_poll_option_proposal_state.dart';

class LivePollOptionProposalCubit extends Cubit<LivePollOptionProposalState> {
  final LivePollRepository repo = getIt<LivePollRepository>();
  final LiveStreamWebSocketManager _wsManager =
      getIt<LiveStreamWebSocketManager>();

  LivePollOptionProposalCubit() : super(const LivePollOptionProposalState());

  Future<void> init({
    required int liveStreamId,
    required int pollId,
    bool connectSocket = true,
  }) async {
    emit(
      state.copyWith(
        liveStreamId: liveStreamId,
        pollId: pollId,
        clearProposals: true,
        clearError: true,
        clearLatestProposal: true,
      ),
    );

    if (connectSocket) {
      _connectProposalSocket(liveStreamId);
    }

    await loadOptionProposals(liveStreamId: liveStreamId, pollId: pollId);
  }

  void _connectProposalSocket(int liveStreamId) {
    _unsubscribeProposalTopic();

    _wsManager.connect(
      logName: 'LivePollOptionProposalCubit',
      onConnected: () {
        _wsManager.subscribeTopic<LivePollOptionProposalResponse>(
          liveStreamId: liveStreamId,
          topic: 'live-poll-proposal',
          fromJson: LivePollOptionProposalResponse.fromJson,
          onData: _handleIncomingProposal,
          logName: 'LivePollOptionProposalCubit',
          logPrefix: 'poll-proposal',
          onError: (error) {
            emit(state.copyWith(error: error));
          },
        );
      },
      onError: (error) {
        emit(state.copyWith(error: error));
      },
    );
  }

  void _handleIncomingProposal(LivePollOptionProposalResponse proposal) {
    if (state.pollId != null && proposal.pollId != state.pollId) {
      return;
    }

    emit(
      state.copyWith(proposals: _upsertProposal(proposal), clearError: true),
    );
  }

  Future<void> loadOptionProposals({
    required int liveStreamId,
    required int pollId,
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

  void setSelectedStatus(PollOptionProposalStatus? status) {
    emit(
      state.copyWith(
        selectedStatus: status,
        clearSelectedStatus: status == null,
      ),
    );
  }

  void reset() {
    emit(const LivePollOptionProposalState());
  }

  void _unsubscribeProposalTopic() {
    final liveStreamId = state.liveStreamId;
    if (liveStreamId == null) return;

    _wsManager.unsubscribeTopic(
      liveStreamId: liveStreamId,
      topic: 'live-poll-proposal',
      logName: 'LivePollOptionProposalCubit',
    );
  }

  List<LivePollOptionProposalResponse> _upsertProposal(
    LivePollOptionProposalResponse proposal,
  ) {
    final updated = state.proposals
        .where((item) => item.id != proposal.id)
        .toList();

    return [proposal, ...updated];
  }

  @override
  Future<void> close() {
    _unsubscribeProposalTopic();
    return super.close();
  }
}
