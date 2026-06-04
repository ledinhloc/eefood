import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_entry_response.g.dart';

@JsonSerializable()
class LeaderboardEntryResponse {
  final int rank;
  final num userId;
  final String? username;
  final String? avatarUrl;
  final num? totalDiamonds;
  LeaderboardEntryResponse({
    required this.rank,
    required this.userId,
    this.username,
    this.avatarUrl,
    this.totalDiamonds,
  });

  factory LeaderboardEntryResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardEntryResponseToJson(this);
}
