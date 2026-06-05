import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/logger.dart';
import 'package:eefood/features/livestream/data/model/leaderboard_entry_response.dart';
import 'package:eefood/features/livestream/data/model/ranked_entry.dart';
import 'package:eefood/features/livestream/domain/repository/live_leaderboard_repository.dart';
import 'package:eefood/features/livestream/presentation/provider/live_leaderboard_state.dart';
import 'package:eefood/features/livestream/presentation/provider/livestream_websocket_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveLeaderboardCubit extends Cubit<LiveLeaderboardState> {
  final LiveLeaderboardRepository repository;
  final LiveStreamWebSocketManager wsManager =
      getIt<LiveStreamWebSocketManager>();
  static const _logName = 'LiveLeaderboardCubit';
  static const _topic = 'live-leaderboard';

  int? _currentLiveStreamId; // Track current livestreamId to detect changes

  LiveLeaderboardCubit({required this.repository})
    : super(const LiveLeaderboardState());

  Future<void> init(int livestreamId) async {
    // Nếu livestreamId khác, unsubscribe livestream cũ và reset state
    if (_currentLiveStreamId != null && _currentLiveStreamId != livestreamId) {
      unsubscribe(_currentLiveStreamId!);
      emit(const LiveLeaderboardState()); // Reset state
    }

    _currentLiveStreamId = livestreamId;
    await loadInitial(livestreamId);
    _subscribeWebSocket(livestreamId);
  }

  Future<void> loadInitial(num livestreamId) async {
    emit(state.copyWith(status: LeaderboardStatus.loading));
    try {
      final entries = await repository.getLeaderBoard(livestreamId);
      logger.e('🏆 Leaderboard loaded: ${entries.length} entries');
      emit(
        state.copyWith(
          status: LeaderboardStatus.loaded,
          entries: _toRanked(entries, previous: []),
        ),
      );
    } catch (e) {
      logger.e('🏆 Leaderboard error: $e');
      emit(
        state.copyWith(status: LeaderboardStatus.error, error: e.toString()),
      );
    }
  }

  void onLeaderboardUpdate(List<LeaderboardEntryResponse> incoming) {
    final updated = _toRanked(incoming, previous: state.entries);
    emit(state.copyWith(status: LeaderboardStatus.loaded, entries: updated));
  }

  void unsubscribe(int livestreamId) {
    if (!isClosed) {
      wsManager.unsubscribeTopic(
        liveStreamId: livestreamId,
        topic: _topic,
        logName: _logName,
      );
    }
  }

  @override
  Future<void> close() {
    if (_currentLiveStreamId != null) {
      unsubscribe(_currentLiveStreamId!);
    }
    return super.close();
  }

  void _subscribeWebSocket(int livestreamId) {
    // If already connected, subscribe immediately; otherwise wait for connection.
    if (wsManager.isConnected) {
      _doSubscribe(livestreamId);
    } else {
      wsManager.connect(
        logName: _logName,
        onConnected: () => _doSubscribe(livestreamId),
      );
    }
  }

  void _doSubscribe(int livestreamId) {
    wsManager.subscribeTopicNew<List<LeaderboardEntryResponse>>(
      liveStreamId: livestreamId,
      topic: _topic,
      logName: _logName,
      logPrefix: 'leaderboard',
      fromJson: (dynamic json) {
        if (json is List) {
          return json
              .map(
                (e) => LeaderboardEntryResponse.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        }
        return <LeaderboardEntryResponse>[];
      },
      onData: onLeaderboardUpdate,
    );
  }

  List<RankedEntry> _toRanked(
    List<LeaderboardEntryResponse> incoming, {
    required List<RankedEntry> previous,
  }) {
    final previousRankMap = {for (final e in previous) e.userId: e.rank};

    return incoming.map((e) {
      final prevRank = previousRankMap[e.userId];
      final RankChange change;

      if (prevRank == null) {
        change = RankChange.newEntry;
      } else if (e.rank < prevRank) {
        change = RankChange.up;
      } else if (e.rank > prevRank) {
        change = RankChange.down;
      } else {
        change = RankChange.none;
      }

      return RankedEntry(
        rank: e.rank,
        userId: e.userId,
        username: e.username,
        avatarUrl: e.avatarUrl,
        totalDiamonds: e.totalDiamonds,
        rankChange: change,
      );
    }).toList();
  }
}
