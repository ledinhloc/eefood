import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/data/models/comment_reaction_model.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/domain/repositories/comment_reaction_repository.dart';

class CommentReactionRepositoryImpl extends CommentReactionRepository {
  final Dio dio;
  CommentReactionRepositoryImpl({required this.dio});

  @override
  Future<CommentReactionModel?> reactToComment(
    int commentId,
    ReactionType type,
  ) async {
    final response = await dio.post(
      '/v1/comment-reactions',
      data: {'commentId': commentId, 'reactionType': type.name},
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return CommentReactionModel.fromJson(response.data['data']);
    }

    return null;
  }

  @override
  Future<void> removeReaction(int commentId) async {
    await dio.delete('/v1/comment-reactions/$commentId');
  }

  @override
  Future<List<CommentReactionModel>> getReactionByComment(int commentId) async {
    final response = await dio.get('/v1/comment-reactions/$commentId');

    if (response.statusCode == 200 &&
        response.data['data'] != null &&
        response.data['data'] is List) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => CommentReactionModel.fromJson(e)).toList();
    }

    return [];
  }

  @override
  Future<Map<ReactionType, int>> getReactionCounts(int commentId) async {
    final response = await dio.get('/v1/comment-reactions/$commentId/counts');

    if (response.statusCode == 200 && response.data['data'] != null) {
      final Map<String, dynamic> data = response.data['data'];
      return data.map((key, value) {
        final reactionType = ReactionTypeX.fromString(key);
        return MapEntry(reactionType!, value as int);
      });
    }
    throw Exception('Failed to get reaction counts');
  }
}
