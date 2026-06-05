// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntryResponse _$LeaderboardEntryResponseFromJson(
        Map<String, dynamic> json) =>
    LeaderboardEntryResponse(
      rank: (json['rank'] as num).toInt(),
      userId: json['userId'] as num,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      totalDiamonds: json['totalDiamonds'] as num?,
    );

Map<String, dynamic> _$LeaderboardEntryResponseToJson(
        LeaderboardEntryResponse instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'userId': instance.userId,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'totalDiamonds': instance.totalDiamonds,
    };
