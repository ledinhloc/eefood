import 'package:eefood/features/livestream/presentation/provider/livestream_websocket_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/data/model/create_live_poll_request.dart';
import 'package:eefood/features/livestream/data/model/live_poll_response.dart';
import 'package:eefood/features/livestream/data/model/poll_result_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_poll_repository.dart';

import 'live_poll_state.dart';

class LivePollCubit extends Cubit<LivePollState> {
  final LivePollRepository repo = getIt<LivePollRepository>();

  LiveStreamWebSocketManager? _wsManager;

  LivePollCubit() : super(const LivePollState());

  /// Gọi khi vào màn livestream
  Future<void> init({
    required int liveStreamId,
    String? pollId,
    bool connectSocket = true,
  }) async {
    emit(
      state.copyWith(
        liveStreamId: liveStreamId,
        clearError: true,
      ),
    );

    if (connectSocket) {
      _connectWebSocket(liveStreamId);
    }

    if (pollId != null && pollId.isNotEmpty) {
      await loadPollDetail(pollId: pollId);
      await loadPollResult(pollId: pollId);
    }
  }

  void _connectWebSocket(int liveStreamId) {
    _wsManager?.disconnect();

    _wsManager = LiveStreamWebSocketManager(
      liveStreamId: liveStreamId,
      logName: 'LivePollCubit',
      onConnected: () {
        emit(state.copyWith(socketConnected: true));
        _subscribePollTopics();
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

    _wsManager!.connect();
  }

  void _subscribePollTopics() {
    final manager = _wsManager;
    if (manager == null) return;

    /// Topic tên chỉ là ví dụ.
    /// Anh/chị sửa lại theo backend thật của mình.

    // Realtime cập nhật thông tin poll: create/open/close/detail
    manager.subscribe<LivePollResponse>(
      topic: 'live-poll',
      fromJson: (json) => LivePollResponse.fromJson(json),
      onData: (data) {
        emit(
          state.copyWith(
            poll: data,
            clearError: true,
          ),
        );
      },
      logPrefix: 'live poll update',
    );

    // Realtime cập nhật kết quả vote
    manager.subscribe<PollResultResponse>(
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
      logPrefix: 'poll result update',
    );

    // Nếu backend có queue riêng theo user, có thể dùng thêm:
    // manager.subscribeUserQueue<PollResultResponse>(
    //   queue: 'live-poll-result',
    //   fromJson: (json) => PollResultResponse.fromJson(json),
    //   onData: (data) {
    //     emit(state.copyWith(result: data, clearError: true));
    //   },
    //   logPrefix: 'user poll result update',
    // );
  }

  Future<void> loadPollDetail({
    required String pollId,
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
    if (liveStreamId == null) return;

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
    required String pollId,
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

      await loadPollResult(pollId: pollId);
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
    required String pollId,
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

      await loadPollResult(pollId: pollId);
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
    required String pollId,
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

  void toggleOption({
    required int optionId,
    bool isMultipleChoice = false,
  }) {
    final current = List<int>.from(state.selectedOptionIds);

    if (isMultipleChoice) {
      if (current.contains(optionId)) {
        current.remove(optionId);
      } else {
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

    emit(state.copyWith(selectedOptionIds: current));
  }

  void clearSelectedOptions() {
    emit(state.copyWith(selectedOptionIds: const []));
  }

  Future<void> vote({
    required String pollId,
  }) async {
    final liveStreamId = state.liveStreamId;
    if (liveStreamId == null) return;

    if (state.selectedOptionIds.isEmpty) {
      emit(state.copyWith(error: 'Vui lòng chọn ít nhất 1 đáp án'));
      return;
    }

    emit(
      state.copyWith(
        actionLoading: true,
        clearError: true,
      ),
    );

    try {
      final result = await repo.vote(
        liveStreamId: liveStreamId,
        pollId: pollId,
        optionIds: state.selectedOptionIds,
      );

      emit(
        state.copyWith(
          actionLoading: false,
          result: result,
          selectedOptionIds: const [],
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

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void disconnectSocket() {
    _wsManager?.disconnect();
    emit(state.copyWith(socketConnected: false));
  }

  @override
  Future<void> close() {
    _wsManager?.disconnect();
    return super.close();
  }
}