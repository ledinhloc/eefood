import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/domain/repositories/comment_repository.dart';

class CommentRepositoryImpl extends CommentRepository{
  final Dio dio;
  CommentRepositoryImpl({required this.dio});

  @override
  Future<CommentModel?> getCommentById(int commentId) async {
    final response = await dio.get('/v1/comments/$commentId');
    if(response.statusCode == 200 && response.data['data'] != null) {
      return CommentModel.fromJson(response.data['data']);
    }
  }

  @override
  Future<CommentModel?> addComment(CommentModel request, int postId) async {
    final response = await dio.post(
      '/v1/comments',
      data: {
        'content': request.content,
        'parentId': request.parentId,
        'postId': postId,
        'images': request.images,
        'videos': request.videos,
      }
    );

    if(response.statusCode == 200 && response.data['data'] != null){
      return CommentModel.fromJson(response.data['data']);
    }
  }

  @override
  Future<List<CommentModel>> getCommentsByPost(int postId, {int page = 1, int limit = 5}) async {
    final response = await dio.get(
      '/v1/comments/post/$postId',
      queryParameters: {
        'page': page,
        'limit': limit,
      }
    );
    final List<dynamic> data = response.data['data']['content'] ?? [];
    print('Post: ' + data.toString());
    return data.map((e) => CommentModel.fromJson(e)).toList();
  }

  @override
  Future<List<CommentModel>> getRepliesByComment(int commentId, {int page = 1, int limit = 5}) async {
    final response = await dio.get(
        '/v1/comments/$commentId/replies',
        queryParameters: {
          'page': page,
          'limit': limit, 
        }
    );
    final List<dynamic> data = response.data['data']['content'] ?? [];
    print('Reply: ' +data.toString());
    return data.map((e) => CommentModel.fromJson(e)).toList();
  }

}