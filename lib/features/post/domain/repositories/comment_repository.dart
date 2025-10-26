import 'package:eefood/features/post/data/models/comment_model.dart';

abstract class CommentRepository {
  Future<CommentModel?> updateComment(int commentId, String body);
  Future<void> deleteComment(int commentId);
  Future<CommentModel?> getCommentById(int commentId);
  Future<CommentModel?> addComment(CommentModel request, int postId);
  Future<List<CommentModel>> getCommentsByPost(int postId, {int page = 1, int limit = 10});
  Future<List<CommentModel>> getRepliesByComment(int commentId, {int page = 1, int limit = 10});
}