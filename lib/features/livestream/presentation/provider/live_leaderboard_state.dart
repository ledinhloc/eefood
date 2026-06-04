import 'package:eefood/features/livestream/data/model/ranked_entry.dart';

class LiveLeaderboardState {
  final List<RankedEntry> entries;
  final LeaderboardStatus status;
  final String? error;

  const LiveLeaderboardState({
    this.entries = const [],
    this.status = LeaderboardStatus.initial,
    this.error,
  });

  bool get isLoading =>
      status == LeaderboardStatus.initial ||
      status == LeaderboardStatus.loading;

  LiveLeaderboardState copyWith({
    List<RankedEntry>? entries,
    LeaderboardStatus? status,
    String? error,
  }) => LiveLeaderboardState(
    entries: entries ?? this.entries,
    status: status ?? this.status,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [entries, status, error];
}
