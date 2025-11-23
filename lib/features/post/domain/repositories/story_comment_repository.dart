import 'package:eefood/features/post/data/models/story_comment_model.dart';

abstract class StoryCommentRepository {
  Future<StoryCommentModel> addComment(
    int storyId,
    String message,
    int parentId,
  );
  Future<StoryCommentModel> udpateComment(int id, String message);
  Future<StoryCommentModel> deleteComment(int commentId);
  Future<StoryCommentPage> getComments(int storyId);
  Future<StoryCommentPage> getRepliesComments(int parentId);
}
