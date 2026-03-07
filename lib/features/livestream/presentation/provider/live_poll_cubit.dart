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

  LiveStreamWebSocketManager? _wsManager;

  LivePollCubit() : super(const LivePollState());

  // khởi tạo poll khi vào livestream
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

    // kết nối websocket realtime
    if (connectSocket) {
      _connectWebSocket(liveStreamId);
    }

    try {
      // có pollId thì load chi tiết poll
      if (pollId != null) {
        await loadPollDetail(pollId: pollId);
      } else {
        // không có pollId thì lấy poll đang mở
        await loadActivePoll();
      }

      // load kết quả nếu được phép hiển thị
      final currentPollId = state.poll?.id;
      if (currentPollId != null) {
        await loadPollResultIfNeeded(pollId: currentPollId);
      }
    } catch (_) {
      // lỗi đã được emit ở từng hàm
    }
  }

  // mở kết nối websocket
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

  // đăng ký các topic realtime của poll
  void _subscribePollTopics() {
    final manager = _wsManager;
    if (manager == null) return;

    // nhận realtime khi poll create/open/close/update
    manager.subscribe<LivePollResponse>(
      topic: 'live-poll',
      fromJson: (json) => LivePollResponse.fromJson(json),
      onData: (data) async {
        // lọc lại các option đã chọn cho đúng poll mới nhất
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

        // poll đóng thì kiểm tra load kết quả
        if (data.status == PollStatus.closed) {
          await loadPollResultIfNeeded(pollId: data.id);
        }
      },
      logPrefix: 'live poll update',
    );

    // nhận realtime khi kết quả vote thay đổi
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
  }

  // lấy poll đang mở của livestream
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

  // lấy chi tiết poll theo id
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

  // streamer tạo poll mới
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

  // streamer mở poll để bắt đầu vote
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

      // load kết quả nếu setting cho phép
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

  // streamer đóng poll để kết thúc vote
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

      // poll đóng thì ép load kết quả
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

  // lấy kết quả poll
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

  // chỉ load kết quả khi đúng policy hiển thị
  Future<void> loadPollResultIfNeeded({
    required int pollId,
    bool force = false,
  }) async {
    if (force || shouldShowResult) {
      await loadPollResult(pollId: pollId);
    }
  }

  // chọn hoặc bỏ chọn đáp án
  void toggleOption({
    required int optionId,
  }) {
    final poll = state.poll;
    if (poll == null) return;

    // check poll đang mở
    if (poll.status != PollStatus.open) {
      emit(state.copyWith(error: 'Bình chọn chưa mở hoặc đã kết thúc'));
      return;
    }

    // check đã vote và không cho đổi lựa chọn
    if (state.hasVoted && !allowChangeVote) {
      emit(state.copyWith(error: 'Bạn đã bình chọn và không thể thay đổi'));
      return;
    }

    final current = List<int>.from(state.selectedOptionIds);

    // check chọn nhiều lựa chọn
    if (isMultipleChoice) {
      if (current.contains(optionId)) {
        // bỏ chọn nếu đã chọn trước đó
        current.remove(optionId);
      } else {
        // check số lượng lựa chọn tối đa
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
      // poll chỉ cho chọn một đáp án
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

  // xóa toàn bộ lựa chọn hiện tại
  void clearSelectedOptions() {
    emit(state.copyWith(selectedOptionIds: const []));
  }

  // gửi vote lên server
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

    // check poll đang mở
    if (poll.status != PollStatus.open) {
      emit(state.copyWith(error: 'Poll chưa mở hoặc đã kết thúc'));
      return;
    }

    // check đã chọn ít nhất một đáp án
    if (state.selectedOptionIds.isEmpty) {
      emit(state.copyWith(error: 'Vui lòng chọn ít nhất 1 đáp án'));
      return;
    }

    // check poll chỉ cho chọn một đáp án
    if (!isMultipleChoice && state.selectedOptionIds.length != 1) {
      emit(state.copyWith(error: 'Poll này chỉ cho chọn 1 đáp án'));
      return;
    }

    // check số lượng đáp án tối đa
    if (isMultipleChoice && state.selectedOptionIds.length > maxChoices) {
      emit(
        state.copyWith(
          error: 'Bạn chỉ được chọn tối đa $maxChoices đáp án',
        ),
      );
      return;
    }

    // check đã vote và không được đổi lựa chọn
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
      // lưu lại lựa chọn đang submit
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

      // giữ result trong state, UI tự quyết định có hiển thị hay không
    } catch (e) {
      emit(
        state.copyWith(
          actionLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  // check poll có cho chọn nhiều không
  bool get isMultipleChoice =>
      state.poll?.setting.multipleChoice ?? false;

  // check có cho đổi lựa chọn sau khi vote không
  bool get allowChangeVote =>
      state.poll?.setting.allowChangeVote ?? false;

  // lấy số lượng lựa chọn tối đa
  int get maxChoices =>
      state.poll?.setting.maxChoices ?? 1;

  // check có được hiển thị kết quả không
  bool get shouldShowResult {
    final poll = state.poll;
    if (poll == null) return false;

    // streamer luôn được xem kết quả
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

  // lọc lại các đáp án đang chọn cho đúng setting hiện tại
  List<int> _sanitizeSelectedOptions({
    required List<int> selected,
    required LivePollResponse poll,
  }) {
    // chỉ giữ các option còn tồn tại trong poll
    final validIds = poll.options.map((e) => e.id).toSet();
    final filtered = selected.where(validIds.contains).toList();

    // poll một lựa chọn thì chỉ giữ lại một option
    if (!poll.setting.multipleChoice) {
      return filtered.isEmpty ? const [] : [filtered.first];
    }

    // poll nhiều lựa chọn thì cắt theo maxChoices
    final limit = poll.setting.maxChoices;
    if (filtered.length <= limit) return filtered;

    return filtered.take(limit).toList();
  }

  // xóa lỗi hiện tại
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  // ngắt kết nối websocket
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