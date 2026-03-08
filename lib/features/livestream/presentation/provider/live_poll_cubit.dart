import 'dart:async';

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/data/model/create_live_poll_request.dart';
import 'package:eefood/features/livestream/data/model/live_poll_response.dart';
import 'package:eefood/features/livestream/data/model/poll_result_response.dart';
import 'package:eefood/features/livestream/domain/enum/poll_result_visibility.dart';
import 'package:eefood/features/livestream/domain/enum/poll_status.dart';
import 'package:eefood/features/livestream/domain/repository/live_poll_repository.dart';
import 'package:eefood/features/livestream/presentation/provider/livestream_websocket_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'live_poll_state.dart';

class LivePollCubit extends Cubit<LivePollState> {
  final LivePollRepository repo = getIt<LivePollRepository>();
  final LiveStreamWebSocketManager _wsManager =
  getIt<LiveStreamWebSocketManager>();

  LivePollCubit() : super(const LivePollState());

  Future<void> init({
    required int liveStreamId,
    bool connectSocket = true,
    bool isHost = false,
    int? pollId,
  }) async {
    emit(
      state.copyWith(
        liveStreamId: liveStreamId,
        isHost: isHost,
        clearError: true,
      ),
    );

    if (connectSocket) {
      _connectWebSocket(liveStreamId);
    }

    try {
      if (pollId != null) {
        await loadPollDetail(pollId: pollId);
      } else {
        await loadActivePoll();
      }

      final currentPollId = state.poll?.id;
      if (currentPollId != null) {
        await loadPollResultIfNeeded(pollId: currentPollId);
      }
    } catch (_) {
      // lỗi đã được emit ở từng hàm
    }
  }

  void _connectWebSocket(int liveStreamId) {
    _unsubscribePollTopics();

    _wsManager.connect(
      logName: 'LivePollCubit',
      onConnected: () {
        emit(state.copyWith(socketConnected: true));
        _subscribePollTopics(liveStreamId);
      },
      onError: (error) {
        emit(
          state.copyWith(
            socketConnected: false,
            error: error,
          ),
        );
      },
    );
  }

  void _subscribePollTopics(int liveStreamId) {
    _wsManager.subscribeTopic<LivePollResponse>(
      liveStreamId: liveStreamId,
      topic: 'live-poll',
      fromJson: (json) => LivePollResponse.fromJson(json),
      onData: (data) async {
        final nextSelected = _sanitizeSelectedOptions(
          selected: state.selectedOptionIds,
          poll: data,
        );

        emit(
          state.copyWith(
            poll: data,
            selectedOptionIds: nextSelected,
            clearError: true,
          ),
        );

        if (data.status == PollStatus.closed) {
          await loadPollResultIfNeeded(pollId: data.id);
        }
      },
      logName: 'LivePollCubit',
      logPrefix: 'live poll update',
      onError: (error) {
        emit(
          state.copyWith(
            socketConnected: false,
            error: error,
          ),
        );
      },
    );

    _wsManager.subscribeTopic<PollResultResponse>(
      liveStreamId: liveStreamId,
      topic: 'live-poll-result',
      fromJson: (json) => PollResultResponse.fromJson(json),
      onData: (data) {
        emit(
          state.copyWith(
            result: data,
            clearError: true,
          ),
        );
      },
      logName: 'LivePollCubit',
      logPrefix: 'poll result update',
      onError: (error) {
        emit(
          state.copyWith(
            socketConnected: false,
            error: error,
          ),
        );
      },
    );
  }

  void _unsubscribePollTopics() {
    final liveStreamId = state.liveStreamId;
    if (liveStreamId == null) return;

    _wsManager.unsubscribeTopic(
      liveStreamId: liveStreamId,
      topic: 'live-poll',
      logName: 'LivePollCubit',
    );

    _wsManager.unsubscribeTopic(
      liveStreamId: liveStreamId,
      topic: 'live-poll-result',
      logName: 'LivePollCubit',
    );
  }

  Future<void> loadActivePoll() async {
    final liveStreamId = state.liveStreamId;
    if (liveStreamId == null) return;

    emit(
      state.copyWith(
        loading: true,
        clearError: true,
      ),
    );

    try {
      final poll = await repo.getActivePoll(liveStreamId: liveStreamId);

      emit(
        state.copyWith(
          loading: false,
          poll: poll,
          selectedOptionIds: _sanitizeSelectedOptions(
            selected: state.selectedOptionIds,
            poll: poll,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          poll: null,
          result: null,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> loadPollDetail({
    required int pollId,
  }) async {
    final liveStreamId = state.liveStreamId;
    if (liveStreamId == null) return;

    emit(
      state.copyWith(
        loading: true,
        clearError: true,
      ),
    );

    try {
      final poll = await repo.getPollDetail(
        liveStreamId: liveStreamId,
        pollId: pollId,
      );

      emit(
        state.copyWith(
          loading: false,
          poll: poll,
          selectedOptionIds: _sanitizeSelectedOptions(
            selected: state.selectedOptionIds,
            poll: poll,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> createPoll({
    required CreateLivePollRequest request,
  }) async {
    final liveStreamId = state.liveStreamId;
    if (liveStreamId == null) {
      emit(state.copyWith(error: 'Không tìm thấy liveStreamId'));
      return;
    }

    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      final poll = await repo.createPoll(
        liveStreamId: liveStreamId,
        request: request,
      );

      emit(
        state.copyWith(
          actionLoading: false,
          poll: poll,
          result: null,
          selectedOptionIds: const [],
          votedOptionIds: const [],
          hasVoted: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> openPoll({
    required int pollId,
  }) async {
    final liveStreamId = state.liveStreamId;
    if (liveStreamId == null) return;

    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      final poll = await repo.openPoll(
        liveStreamId: liveStreamId,
        pollId: pollId,
      );

      emit(
        state.copyWith(
          actionLoading: false,
          poll: poll,
        ),
      );

      await loadPollResultIfNeeded(pollId: pollId);
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> closePoll({
    required int pollId,
  }) async {
    final liveStreamId = state.liveStreamId;
    if (liveStreamId == null) return;

    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      final poll = await repo.closePoll(
        liveStreamId: liveStreamId,
        pollId: pollId,
      );

      emit(
        state.copyWith(
          actionLoading: false,
          poll: poll,
        ),
      );

      await loadPollResultIfNeeded(pollId: pollId, force: true);
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> loadPollResult({
    required int pollId,
  }) async {
    final liveStreamId = state.liveStreamId;
    if (liveStreamId == null) return;

    emit(
      state.copyWith(
        loading: true,
        clearError: true,
      ),
    );

    try {
      final result = await repo.getPollResult(
        liveStreamId: liveStreamId,
        pollId: pollId,
      );

      emit(
        state.copyWith(
          loading: false,
          result: result,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> loadPollResultIfNeeded({
    required int pollId,
    bool force = false,
  }) async {
    if (force || shouldShowResult) {
      await loadPollResult(pollId: pollId);
    }
  }

  void toggleOption({
    required int optionId,
  }) {
    final poll = state.poll;
    if (poll == null) return;

    if (poll.status != PollStatus.open) {
      emit(state.copyWith(error: 'Bình chọn chưa mở hoặc đã kết thúc'));
      return;
    }

    if (state.hasVoted && !allowChangeVote) {
      emit(state.copyWith(error: 'Bạn đã bình chọn và không thể thay đổi'));
      return;
    }

    final current = List<int>.from(state.selectedOptionIds);

    if (isMultipleChoice) {
      if (current.contains(optionId)) {
        current.remove(optionId);
      } else {
        if (current.length >= maxChoices) {
          emit(
            state.copyWith(
              error: 'Chỉ được chọn tối đa $maxChoices đáp án',
            ),
          );
          return;
        }
        current.add(optionId);
      }
    } else {
      if (current.contains(optionId)) {
        current.clear();
      } else {
        current
          ..clear()
          ..add(optionId);
      }
    }

    emit(
      state.copyWith(
        selectedOptionIds: current,
        clearError: true,
      ),
    );
  }

  void clearSelectedOptions() {
    emit(state.copyWith(selectedOptionIds: const []));
  }

  Future<void> vote({
    required int pollId,
  }) async {
    final liveStreamId = state.liveStreamId;
    if (liveStreamId == null) return;

    final poll = state.poll;
    if (poll == null) {
      emit(state.copyWith(error: 'Không tìm thấy poll'));
      return;
    }

    if (poll.status != PollStatus.open) {
      emit(state.copyWith(error: 'Poll chưa mở hoặc đã kết thúc'));
      return;
    }

    if (state.selectedOptionIds.isEmpty) {
      emit(state.copyWith(error: 'Vui lòng chọn ít nhất 1 đáp án'));
      return;
    }

    if (!isMultipleChoice && state.selectedOptionIds.length != 1) {
      emit(state.copyWith(error: 'Poll này chỉ cho chọn 1 đáp án'));
      return;
    }

    if (isMultipleChoice && state.selectedOptionIds.length > maxChoices) {
      emit(
        state.copyWith(
          error: 'Bạn chỉ được chọn tối đa $maxChoices đáp án',
        ),
      );
      return;
    }

    if (state.hasVoted && !allowChangeVote) {
      emit(state.copyWith(error: 'Bạn đã bình chọn rồi'));
      return;
    }

    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      final submitted = List<int>.from(state.selectedOptionIds);

      final result = await repo.vote(
        liveStreamId: liveStreamId,
        pollId: pollId,
        optionIds: submitted,
      );

      emit(
        state.copyWith(
          actionLoading: false,
          result: result,
          hasVoted: true,
          votedOptionIds: submitted,
          selectedOptionIds: submitted,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  bool get isMultipleChoice =>
      state.poll?.setting.multipleChoice ?? false;

  bool get allowChangeVote =>
      state.poll?.setting.allowChangeVote ?? false;

  int get maxChoices =>
      state.poll?.setting.maxChoices ?? 1;

  bool get shouldShowResult {
    final poll = state.poll;
    if (poll == null) return false;

    if (state.isHost) return true;

    final visibility = poll.setting.resultVisibility;

    switch (visibility) {
      case PollResultVisibility.always:
        return true;
      case PollResultVisibility.afterVote:
        return state.hasVoted;
      case PollResultVisibility.afterClose:
        return poll.status == PollStatus.closed;
    }
  }

  List<int> _sanitizeSelectedOptions({
    required List<int> selected,
    required LivePollResponse poll,
  }) {
    final validIds = poll.options.map((e) => e.id).toSet();
    final filtered = selected.where(validIds.contains).toList();

    if (!poll.setting.multipleChoice) {
      return filtered.isEmpty ? const [] : [filtered.first];
    }

    final limit = poll.setting.maxChoices;
    if (filtered.length <= limit) return filtered;

    return filtered.take(limit).toList();
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void disconnectSocket() {
    _unsubscribePollTopics();
    emit(state.copyWith(socketConnected: false));
  }

  @override
  Future<void> close() {
    _unsubscribePollTopics();
    return super.close();
  }
}