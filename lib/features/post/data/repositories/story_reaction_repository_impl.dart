import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/data/models/story_reaction_model.dart';
import 'package:eefood/features/post/domain/repositories/story_reaction_repository.dart';

class StoryReactionRepositoryImpl extends StoryReactionRepository {
  final Dio dio;
  StoryReactionRepositoryImpl({required this.dio});

  @override
  Future<StoryReactionModel?> getCurrentUserReaction(int storyId) async {
    try {
      final response = await dio.get('/v1/story-reactions/$storyId/current');

      if (response.statusCode == 200 && response.data['data'] != null) {
        return StoryReactionModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load current user reaction $e');
    }
  }

  @override
  Future<StoryReactionModel?> reactToStory(
    int storyId,
    ReactionType type,
  ) async {
    try {
      final response = await dio.post(
        '/v1/story-reactions',
        data: {'storyId': storyId, 'reactionType': type.name},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return StoryReactionModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to react story $e');
    }
  }

  @override
  Future<void> removeReaction(int storyId) async {
    try {
      await dio.delete('/v1/story-reactions/$storyId');
    } catch (e) {
      throw Exception('Failed to deleted reaction story $e');
    }
  }

  @override
  Future<StoryReactionPage> getUserReactedStory(
    int storyId, {
    int page = 1,
    int limit = 5,
  }) async {
    try {
      final response = await dio.get(
        '/v1/story-reactions/$storyId/users',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return StoryReactionPage.fromJson(data);
      }
      return StoryReactionPage(
        totalElements: 0,
        numberOfElements: 0,
        reactions: [],
      );
    } catch (e) {
      throw Exception('Failed to load story reactions $e');
    }
  }
}
