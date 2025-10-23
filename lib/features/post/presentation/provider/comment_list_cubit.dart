import 'dart:io';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/data/models/comment_reaction_model.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/domain/repositories/comment_reaction_repository.dart';
import 'package:eefood/features/post/domain/repositories/comment_repository.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentListCubit extends Cubit<CommentListState> {
  final CommentRepository _repository = getIt<CommentRepository>();
  final CommentReactionRepository _reactRepo =
      getIt<CommentReactionRepository>();
  final FileUploader _uploader = getIt<FileUploader>();
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();
  int? _currentPostId;

  CommentListCubit()
    : super(
        CommentListState(
          comments: [],
          isLoading: false,
          hasMore: true,
          currentPage: 1,
        ),
      );

  // Update comment
  Future<void> updateComment(int commentId, String body) async {
    emit(state.copyWith(isLoading: true));
    try {
      final updated = await _repository.updateComment(commentId, body);
      final updatedComments = _updateCommentInList(
        state.comments,
        commentId,
        updated!,
      );
      emit(state.copyWith(comments: updatedComments, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Lỗi khi cập nhật: $e'),
      );
    }
  }

  /// Delete comment
  Future<void> deleteComment(int commentId) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.deleteComment(commentId);
      final updatedComments = _removeCommentFromList(state.comments, commentId);
      emit(state.copyWith(comments: updatedComments, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Lỗi khi xóa: $e'));
    }
  }

  List<CommentModel> _updateCommentInList(
    List<CommentModel> comments,
    int commentId,
    CommentModel updatedComment,
  ) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        return updatedComment.copyWith(
          replies: comment.replies,
          replyCount: comment.replyCount,
        );
      }
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        return comment.copyWith(
          replies: _updateCommentInList(
            comment.replies!,
            commentId,
            updatedComment,
          ),
        );
      }
      return comment;
    }).toList();
  }

  List<CommentModel> _removeCommentFromList(
    List<CommentModel> comments,
    int commentId,
  ) {
    return comments.where((comment) {
      if (comment.id == commentId) {
        return false; // Remove this comment
      }
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        // Update replies recursively
        final updatedReplies = _removeCommentFromList(
          comment.replies!,
          commentId,
        );
        comment = comment.copyWith(replies: updatedReplies);
      }
      return true; // Keep this comment
    }).toList();
  }

  Future<List<CommentModel>> _loadCurrentUserReactions(
    List<CommentModel> comments,
  ) async {
    final user = await _getCurrentUser();
    if (user == null) return comments;

    return Future.wait(
      comments.map((c) async {
        try {
          final reactions = await _reactRepo.getReactionByComment(c.id!);
          final userReaction = reactions
              .where((r) => r.userId == user.id)
              .firstOrNull
              ?.reactionType;
          return c.copyWith(currentUserReaction: userReaction);
        } catch (_) {
          return c;
        }
      }),
    );
  }

  List<CommentModel> updateCommentRecursively(
    List<CommentModel> comments,
    int targetId,
    CommentModel Function(CommentModel) updateFn,
  ) {
    return comments.map((comment) {
      if (comment.id == targetId) return updateFn(comment);
      if (comment.replies?.isNotEmpty ?? false) {
        return comment.copyWith(
          replies: updateCommentRecursively(
            comment.replies!,
            targetId,
            updateFn,
          ),
        );
      }
      return comment;
    }).toList();
  }

  Future<void> removeReaction(int commentId) async {
    try {
      await _reactRepo.removeReaction(commentId);

      final updatedComments = updateCommentRecursively(
        state.comments,
        commentId,
        (comment) {
          final currentType = comment.currentUserReaction;
          if (currentType == null) return comment;

          final updatedCounts = Map<ReactionType, int>.from(
            comment.reactionCounts ?? {},
          );
          updatedCounts[currentType] = (updatedCounts[currentType] ?? 1) - 1;
          if (updatedCounts[currentType]! <= 0)
            updatedCounts.remove(currentType);

          return comment.copyWith(
            reactionCounts: updatedCounts,
            currentUserReaction: null,
          );
        },
      );

      emit(state.copyWith(comments: updatedComments));
    } catch (err) {
      print('Error remove reaction: $err');
    }
  }

  Future<void> reactToComment(int commentId, ReactionType type) async {
    try {
      await _reactRepo.reactToComment(commentId, type);

      final updatedComments = updateCommentRecursively(
        state.comments,
        commentId,
        (comment) {
          final updatedCounts = Map<ReactionType, int>.from(
            comment.reactionCounts ?? {},
          );
          final currentType = comment.currentUserReaction;

          if (currentType == type) {
            // Toggle off
            updatedCounts[type] = (updatedCounts[type] ?? 1) - 1;
            if (updatedCounts[type]! <= 0) updatedCounts.remove(type);
            return comment.copyWith(
              reactionCounts: updatedCounts,
              currentUserReaction: null,
            );
          }

          if (currentType != null && currentType != type) {
            updatedCounts[currentType] = (updatedCounts[currentType] ?? 1) - 1;
            if (updatedCounts[currentType]! <= 0)
              updatedCounts.remove(currentType);
          }

          updatedCounts[type] = (updatedCounts[type] ?? 0) + 1;
          return comment.copyWith(
            reactionCounts: updatedCounts,
            currentUserReaction: type,
          );
        },
      );

      emit(state.copyWith(comments: updatedComments));
    } catch (err) {
      print('Error react to comment: $err');
    }
  }

  void resetForNewPost() {
    emit(
      CommentListState(
        comments: [],
        isLoading: false,
        hasMore: true,
        currentPage: 1,
      ),
    );
    _currentPostId = null;
  }

  Future<void> fetchComments(int postId, {bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    // Nếu là post khác, reset state
    if (!loadMore && _currentPostId != postId) {
      emit(
        state.copyWith(
          comments: [],
          isLoading: true,
          hasMore: true,
          currentPage: 1,
          replyingTo: null,
        ),
      );
    } else {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }

    _currentPostId = postId;
    final nextPage = loadMore ? state.currentPage + 1 : 1;

    try {
      final comments = await _repository.getCommentsByPost(
        postId,
        page: nextPage,
        limit: 5,
      );
      final withUserReactions = await _loadCurrentUserReactions(comments);

      emit(
        state.copyWith(
          comments: loadMore
              ? [...state.comments, ...withUserReactions]
              : withUserReactions,
          isLoading: false,
          hasMore: comments.length == 5,
          currentPage: nextPage,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> fetchRepliesComment(int parentId) async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));

    try {
      final newReplies = await _repository.getRepliesByComment(
        parentId,
        page: 1,
        limit: 10,
      );
      final withUserReactions = await _loadCurrentUserReactions(newReplies);

      final updatedComments = updateCommentRecursively(
        state.comments,
        parentId,
        (c) => c.copyWith(replies: withUserReactions),
      );

      emit(state.copyWith(comments: updatedComments, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> submitComment({
    required int postId,
    int? parentId,
    required String content,
    List<String> images = const [],
    List<String> videos = const [],
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true));

    try {
      final newComment = CommentModel(
        content: content,
        parentId: parentId,
        images: images,
        videos: videos,
      );
      await _repository.addComment(newComment, postId);

      emit(state.copyWith(isSubmitting: false, resetReplyingTo: true));
      await fetchComments(postId);
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
          resetReplyingTo: true,
        ),
      );
    }
  }

  void setReplyingTo(CommentModel? comment) {
    emit(
      (state.replyingTo?.id == comment?.id)
          ? state.copyWith(resetReplyingTo: true)
          : state.copyWith(replyingTo: comment, replyKey: state.replyKey! + 1),
    );
  }

  void cancelReply() {
    if (!state.resetReplyingTo) emit(state.copyWith(resetReplyingTo: true));
  }

  // Upload hình/video
  Future<List<String>> uploadMediaFiles(List<File> files) async {
    final urls = <String>[];
    for (final f in files) {
      try {
        urls.add(await _uploader.uploadFile(f));
      } catch (e) {
        throw Exception('Upload failed: $e');
      }
    }
    return urls;
  }
}
