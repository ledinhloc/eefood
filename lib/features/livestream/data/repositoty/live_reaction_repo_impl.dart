import 'package:dio/dio.dart';
import 'package:eefood/features/livestream/data/model/live_reaction_response.dart';

import '../../domain/repository/live_reaction_repo.dart';

class LiveReactionRepositoryImpl extends LiveReactionRepository {
  final Dio dio;

  LiveReactionRepositoryImpl({required this.dio});
  @override
  Future<List<LiveReactionResponse>> getReactions(int liveStreamId) async {
    final res = await dio.get(
      '/v1/livestreams/$liveStreamId/reactions',
    );

    final data = res.data['data'] as List;
    return data
        .map((json) => LiveReactionResponse.fromJson(json))
        .toList();
  }

  @override
  Future<LiveReactionResponse> createReaction(
      int liveStreamId, String emotion) async {
    final res = await dio.post(
      '/v1/livestreams/$liveStreamId/reactions',
      queryParameters: {'emotion': emotion},
    );

    return LiveReactionResponse.fromJson(res.data['data']);
  }
}
