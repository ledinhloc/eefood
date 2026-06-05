import 'package:eefood/features/livestream/data/model/leaderboard_entry_response.dart';

abstract class LiveLeaderboardRepository {
  Future<List<LeaderboardEntryResponse>> getLeaderBoard(num livestreamId);
}
