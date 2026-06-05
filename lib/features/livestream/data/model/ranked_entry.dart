import 'package:eefood/features/livestream/data/model/leaderboard_entry_response.dart';

enum LeaderboardStatus { initial, loading, loaded, error }
enum RankChange { up, down, none, newEntry }

class RankedEntry extends LeaderboardEntryResponse {
  final RankChange rankChange;

  RankedEntry({
    required super.rank,
    required super.userId,
    super.username,
    super.avatarUrl,
    super.totalDiamonds,
    this.rankChange = RankChange.none,
  });

  RankedEntry copyWithChange(RankChange change) => RankedEntry(
    rank: rank,
    userId: userId,
    username: username,
    avatarUrl: avatarUrl,
    totalDiamonds: totalDiamonds,
    rankChange: change,
  );
}
