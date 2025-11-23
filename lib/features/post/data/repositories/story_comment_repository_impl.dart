import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/story_comment_model.dart';
import 'package:eefood/features/post/domain/repositories/story_comment_repository.dart';

class StoryCommentRepositoryImpl extends StoryCommentRepository {
  final Dio dio;
  StoryCommentRepositoryImpl({required this.dio});

  @override
  Future<StoryCommentModel> addComment(
    int storyId,
    String message,
    int parentId,
  ) async {
    try {
      final Map<String, dynamic> data = {
        'storyId': storyId,
        'message': message,
      };
      if (parentId != 0) {
        data['parentId'] = parentId;
      }
      final response = await dio.post('/v1/story/comments', data: data);
      if (response.statusCode != 200) {
        throw new Exception('Failed to add comment');
      } else {
        final data = StoryCommentModel.fromJson(response.data['data']);
        return data;
      }
    } catch (e) {
      throw new Exception('Failed to add comment $e');
    }
  }

  @override
  Future<StoryCommentModel> udpateComment(int id, String message) async {
    try {
      final response = await dio.put(
        '/v1/story/comments',
        data: {'id': id, 'message': message},
      );

      if (response.statusCode != 200) {
        throw new Exception('Failed to update comment');
      } else {
        final data = StoryCommentModel.fromJson(response.data['data']);
        return data;
      }
    } catch (e) {
      throw new Exception('Failed to update comment $e');
    }
  }

  @override
  Future<StoryCommentModel> deleteComment(int commentId) async {
    try {
      final response = await dio.delete('/v1/story/comments/$commentId');
      if (response.statusMessage == null) {
        throw new Exception('Failed to delete comment');
      } else {
        final data = StoryCommentModel.fromJson(response.data['data']);
        return data;
      }
    } catch (e) {
      throw new Exception('Failed to update comment $e');
    }
  }

  @override
  Future<StoryCommentPage> getComments(int storyId) async {
    try {
      final response = await dio.get('/v1/story/comments/$storyId');
      if (response.statusCode != 200) {
        throw new Exception('Failed to delete comment');
      } else {
        final data = response.data['data'];
        return StoryCommentPage.fromJson(data);
      }
    } catch (e) {
      throw new Exception('Failed to update comment $e');
    }
  }

  @override
  Future<StoryCommentPage> getRepliesComments(int parentId) async {
    try {
      final response = await dio.get('/v1/story/comments/replies/$parentId');
      if (response.statusCode != 200) {
        throw new Exception('Failed to delete comment');
      } else {
        final data = response.data['data'];
        return StoryCommentPage.fromJson(data);
      }
    } catch (e) {
      throw new Exception('Failed to update comment $e');
    }
  }
}
