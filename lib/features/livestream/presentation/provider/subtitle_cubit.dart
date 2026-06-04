import 'dart:developer' as developer;

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/data/model/live_subtitle_message.dart';
import 'package:eefood/features/livestream/data/model/subtitle_subscription_request.dart';
import 'package:eefood/features/livestream/domain/enum/subtitle_language.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'livestream_websocket_manager.dart';
import 'subtitle_state.dart';

class SubtitleCubit extends Cubit<SubtitleState> {
  static const String _subtitleQueue = 'livestream/subtitles';
  static const String _subtitleRegisterDestination =
      '/app/live/subtitles/register';

  final LiveStreamWebSocketManager _wsManager =
      getIt<LiveStreamWebSocketManager>();

  int? _currentStreamId;

  SubtitleCubit() : super(const SubtitleState());

  // Emit an toàn để tránh cập nhật state sau khi cubit đã dispose.
  void _safeEmit(SubtitleState newState) {
    if (!isClosed) emit(newState);
  }

  // Gắn cubit với livestream hiện tại và xóa dữ liệu phụ đề cũ.
  void attachToStream(int liveStreamId) {
    _currentStreamId = liveStreamId;
    _wsManager.unsubscribeUserQueue(queue: _subtitleQueue, logName: 'Subtitle');
    _safeEmit(
      state.copyWith(
        clearLatestSubtitle: true,
        clearSubtitleError: true,
        isSubtitleConnected: false,
      ),
    );
  }

  // Đảm bảo websocket dùng chung đã sẵn sàng, sau đó chỉ subscribe/register
  // phụ đề khi ngôn ngữ hiện tại không phải off.
  void ensureConnected() {
    final liveStreamId = _currentStreamId;
    if (liveStreamId == null) return;
    if (state.selectedSubtitleLanguage == SubtitleLanguage.off) {
      _stopSubtitleStream();
      return;
    }

    _wsManager.connect(
      logName: 'Subtitle',
      onError: (error) {
        developer.log('Subtitle WS error: $error', name: 'Subtitle');
        _safeEmit(
          state.copyWith(isSubtitleConnected: false, subtitleError: error),
        );
      },
      onConnected: () {
        if (state.selectedSubtitleLanguage == SubtitleLanguage.off) {
          _stopSubtitleStream();
          return;
        }
        _subscribeToSubtitles(liveStreamId);
        _registerSubtitle(
          liveStreamId: liveStreamId,
          targetLanguage: state.selectedSubtitleLanguage,
        );
      },
    );
  }

  // Lắng nghe các message phụ đề từ queue riêng của người xem.
  void _subscribeToSubtitles(int liveStreamId) {
    _wsManager.subscribeUserQueue<LiveSubtitleMessage>(
      queue: _subtitleQueue,
      fromJson: LiveSubtitleMessage.fromJson,
      onData: _handleSubtitleMessage,
      logName: 'Subtitle',
      logPrefix: 'subtitle',
      onError: (error) {
        developer.log('Subtitle queue error: $error', name: 'Subtitle');
        _safeEmit(
          state.copyWith(isSubtitleConnected: false, subtitleError: error),
        );
      },
    );

    _safeEmit(
      state.copyWith(isSubtitleConnected: true, clearSubtitleError: true),
    );

    developer.log(
      'Subscribed subtitle queue for stream $liveStreamId',
      name: 'Subtitle',
    );
  }

  // Chỉ nhận phụ đề thuộc đúng stream hiện tại và đúng ngôn ngữ đang chọn.
  void _handleSubtitleMessage(LiveSubtitleMessage message) {
    final currentStreamId = _currentStreamId;
    if (currentStreamId == null || message.liveStreamId != currentStreamId) {
      developer.log(
        'Ignored subtitle for stream ${message.liveStreamId}',
        name: 'Subtitle',
      );
      return;
    }

    if (message.targetLanguage != state.selectedSubtitleLanguage) {
      developer.log(
        'Ignored subtitle for language ${message.targetLanguage.code}',
        name: 'Subtitle',
      );
      return;
    }

    if (message.text.trim().isEmpty) return;

    _safeEmit(
      state.copyWith(
        latestSubtitle: message,
        clearSubtitleError: true,
        isSubtitleConnected: true,
      ),
    );
  }

  // Đổi ngôn ngữ phụ đề từ UI và đăng ký lại nếu cần.
  void changeSubtitleLanguage(SubtitleLanguage language) {
    _safeEmit(
      state.copyWith(
        selectedSubtitleLanguage: language,
        clearLatestSubtitle: true,
        clearSubtitleError: true,
        isSubtitleConnected: language == SubtitleLanguage.off
            ? false
            : state.isSubtitleConnected,
      ),
    );

    final liveStreamId = _currentStreamId;
    if (liveStreamId == null) return;

    if (language == SubtitleLanguage.off) {
      _stopSubtitleStream();
      return;
    }

    if (_wsManager.isConnected) {
      _registerSubtitle(liveStreamId: liveStreamId, targetLanguage: language);
      return;
    }

    ensureConnected();
  }

  // Gửi lên server ngôn ngữ phụ đề mà người xem muốn nhận.
  void _registerSubtitle({
    required int liveStreamId,
    required SubtitleLanguage targetLanguage,
  }) {
    final request = SubtitleSubscriptionRequest(
      liveStreamId: liveStreamId,
      targetLanguage: targetLanguage,
    );

    final sent = _wsManager.send(
      destination: _subtitleRegisterDestination,
      body: request.toJson(),
      logName: 'Subtitle',
      onError: (error) {
        developer.log('Subtitle register error: $error', name: 'Subtitle');
        _safeEmit(
          state.copyWith(isSubtitleConnected: false, subtitleError: error),
        );
      },
    );

    if (sent) {
      _safeEmit(
        state.copyWith(isSubtitleConnected: true, clearSubtitleError: true),
      );
    }
  }

  // Đánh dấu kết nối phụ đề đang mất mà không xóa ngôn ngữ đã chọn.
  void clearConnectionState() {
    _safeEmit(state.copyWith(isSubtitleConnected: false));
  }

  // Chỉ dừng luồng phụ đề, không ngắt websocket dùng chung của livestream.
  void _stopSubtitleStream() {
    _wsManager.unsubscribeUserQueue(queue: _subtitleQueue, logName: 'Subtitle');
    _safeEmit(
      state.copyWith(
        clearLatestSubtitle: true,
        clearSubtitleError: true,
        isSubtitleConnected: false,
      ),
    );
  }

  // Dọn tài nguyên phụ đề của stream hiện tại khi rời màn hình xem live.
  void disposeStream() {
    _currentStreamId = null;
    _stopSubtitleStream();
  }

  @override
  // Đảm bảo đã dọn subscription phụ đề trước khi cubit bị dispose.
  Future<void> close() async {
    disposeStream();
    return super.close();
  }
}
