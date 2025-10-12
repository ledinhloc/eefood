
import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/post_reaction_model.dart';
import 'package:eefood/features/post/domain/repositories/post_reaction_repository.dart';

import '../models/reaction_type.dart';

class PostReactionRepositoryImpl extends PostReactionRepository{
  final Dio dio;
  PostReactionRepositoryImpl({required this.dio});

  @override
  Future<List<PostReactionModel>> getReactionByPosts(int postId) async {
    final response = await dio.get('/v1/post-reactions/$postId');
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((e) => PostReactionModel.fromJson(e)).toList();
  }

  @override
  Future<PostReactionModel?> reactToPost(int postId, ReactionType type) async {
    final response = await dio.post(
        '/v1/post-reactions',
        data: {
          'postId': postId,
          'reactionType': type.name
        }
    );

    if(response.statusCode == 200 && response.data['data'] != null){
      return PostReactionModel.fromJson(response.data['data']);
    }
    return null;
  }

  @override
  Future<void> removeReaction(int postId) async {
    await dio.delete('/v1/post-reactions/$postId');
  }

}