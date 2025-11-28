import 'package:dio/dio.dart';
import 'package:eefood/features/livestream/data/model/live_comment_response.dart';

import '../../domain/repository/live_comment_repo.dart';

class LiveCommentRepositoryImpl extends LiveCommentRepository {
  final Dio dio;
  LiveCommentRepositoryImpl({required this.dio});
  @override
  Future<List<LiveCommentResponse>> getComments(int liveStreamId) async {
    final res = await dio.get(
      '/v1/livestreams/$liveStreamId/comments',
    );

    final data = res.data['data'] as List;
    return data
        .map((json) => LiveCommentResponse.fromJson(json))
        .toList();
  }

  @override
  Future<LiveCommentResponse> createComment(int liveId, String message) async {
    final res = await dio.post(
      '/v1/livestreams/$liveId/comments',
      queryParameters: {'message': message},
    );

    return LiveCommentResponse.fromJson(res.data['data']);
  }

  @override
  Future<LiveCommentResponse> updateComment(int commentId, String message) async {
    final res = await dio.put(
      '/v1/livestreams/comments/$commentId',
      queryParameters: {'message': message},
    );

    return LiveCommentResponse.fromJson(res.data['data']);
  }

  @override
  Future<void> deleteComment(int commentId) async {
    await dio.delete('/v1/livestreams/comments/$commentId');
  }
}
