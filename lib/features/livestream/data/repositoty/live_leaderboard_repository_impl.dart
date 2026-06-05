import 'package:dio/dio.dart';
import 'package:eefood/features/livestream/data/model/leaderboard_entry_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_leaderboard_repository.dart';
import 'package:flutter/foundation.dart';

class LiveLeaderboardRepositoryImpl extends LiveLeaderboardRepository {
  final Dio dio;
  LiveLeaderboardRepositoryImpl({required this.dio});

  @override
  Future<List<LeaderboardEntryResponse>> getLeaderBoard(
    num livestreamId,
  ) async {
    try {
      final response = await dio.get(
        '/v1/livestreams/$livestreamId/leaderboard',
      );
      debugPrint('🏆 API response: ${response.statusCode} ${response.data}');
      final data = response.data;
      final json = data['data'];
      if (json != null && response.statusCode == 200) {
        return (json as List)
            .map(
              (r) =>
                  LeaderboardEntryResponse.fromJson(r as Map<String, dynamic>),
            )
            .toList();
      }
      return List.empty();
    } catch (e) {
      debugPrint('🏆 Repository error: $e');
      throw Exception('Failed to get leader board');
    }
  }
}
