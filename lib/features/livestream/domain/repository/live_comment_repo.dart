import '../../data/model/live_comment_response.dart';

abstract class LiveCommentRepository{
  Future<List<LiveCommentResponse>> getComments(int liveStreamId);
  Future<LiveCommentResponse> createComment(int liveId, String message);
  Future<LiveCommentResponse> updateComment(int commentId, String message);
  Future<void> deleteComment(int commentId);
}