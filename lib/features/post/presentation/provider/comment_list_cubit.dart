import 'dart:io';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
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

  CommentListCubit() : super(CommentListStateExtensions.initial());

  CommentModel _mergeComments(
    CommentModel oldComment,
    CommentModel newComment,
  ) {
    return oldComment.copyWith(
      id: newComment.id ?? oldComment.id,
      userId: newComment.userId ?? oldComment.userId,
      parentId: newComment.parentId ?? oldComment.parentId,
      content: newComment.content,
      createdAt: newComment.createdAt ?? oldComment.createdAt,
      reactionCounts: newComment.reactionCounts ?? oldComment.reactionCounts,
      images: newComment.images ?? oldComment.images,
      videos: newComment.videos ?? oldComment.videos,
      currentUserReaction:
          newComment.currentUserReaction ?? oldComment.currentUserReaction,
    );
  }

  Future<void> _executeWithLoading(
    Future<void> Function() action, {
    bool resetReplyingTo = false,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      await action();
      emit(state.copyWith(isLoading: false, resetReplyingTo: resetReplyingTo));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Lỗi: $e',
          resetReplyingTo: resetReplyingTo,
        ),
      );
    }
  }

  Future<void> updateComment(int commentId, String body) async {
    await _executeWithLoading(() async {
      final updated = await _repository.updateComment(commentId, body);
      final updatedComments = _updateCommentInListRecursive(
        state.comments,
        commentId,
        updated!,
      );
      emit(state.copyWith(comments: updatedComments));
    }, resetReplyingTo: true);
  }

  Future<void> deleteComment(int commentId) async {
    await _executeWithLoading(() async {
      await _repository.deleteComment(commentId);
      final updatedComments = _removeCommentFromListRecursive(
        state.comments,
        commentId,
      );
      emit(state.copyWith(comments: updatedComments));
    });
  }

  List<CommentModel> _updateCommentInListRecursive(
    List<CommentModel> comments,
    int commentId,
    CommentModel updatedComment,
  ) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        return _mergeComments(comment, updatedComment);
      }
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        final updatedReplies = _updateCommentInListRecursive(
          comment.replies!,
          commentId,
          updatedComment,
        );
        // Luôn trả về comment với replies đã cập nhật
        return comment.copyWith(replies: updatedReplies);
      }
      return comment;
    }).toList();
  }

  List<CommentModel> _removeCommentFromListRecursive(
    List<CommentModel> comments,
    int commentId,
  ) {
    final result = <CommentModel>[];

    for (final comment in comments) {
      if (comment.id == commentId) {
        continue; // Bỏ qua comment cần xóa
      }

      // Xử lý replies nếu có
      final updatedReplies =
          comment.replies != null && comment.replies!.isNotEmpty
          ? _removeCommentFromListRecursive(comment.replies!, commentId)
          : comment.replies;

      result.add(comment.copyWith(replies: updatedReplies));
    }

    return result;
  }

  Future<List<CommentModel>> _loadCurrentUserReactions(
    List<CommentModel> comments,
  ) async {
    final user = await _getCurrentUser();
    if (user == null) return comments;

    return Future.wait(
      comments.map((comment) async {
        try {
          final reactions = await _reactRepo.getReactionByComment(comment.id!);
          final userReaction = reactions
              .where((r) => r.userId == user.id)
              .firstOrNull
              ?.reactionType;
          return comment.copyWith(currentUserReaction: userReaction);
        } catch (_) {
          return comment;
        }
      }),
    );
  }

  List<CommentModel> _updateCommentRecursively(
    List<CommentModel> comments,
    int targetId,
    CommentModel Function(CommentModel) updateFn,
  ) {
    return comments.map((comment) {
      if (comment.id == targetId) {
        return updateFn(comment);
      }
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        final updatedReplies = _updateCommentRecursively(
          comment.replies!,
          targetId,
          updateFn,
        );
        return comment.copyWith(replies: updatedReplies);
      }
      return comment;
    }).toList();
  }

  Future<void> _handleReactionUpdate(
    int commentId,
    Future<void> Function() reactionAction,
    CommentModel Function(CommentModel) updateFn,
  ) async {
    try {
      await reactionAction();
      final updatedComments = _updateCommentRecursively(
        state.comments,
        commentId,
        updateFn,
      );
      emit(state.copyWith(comments: updatedComments));
    } catch (err) {
      print('Error handling reaction: $err');
    }
  }

  Future<void> removeReaction(int commentId) async {
    await _handleReactionUpdate(
      commentId,
      () => _reactRepo.removeReaction(commentId),
      (comment) {
        final currentType = comment.currentUserReaction;
        if (currentType == null) return comment;

        final updatedCounts = Map<ReactionType, int>.from(
          comment.reactionCounts ?? {},
        );
        updatedCounts[currentType] = (updatedCounts[currentType] ?? 1) - 1;
        if (updatedCounts[currentType]! <= 0) updatedCounts.remove(currentType);

        return comment.copyWith(
          reactionCounts: updatedCounts,
          currentUserReaction: null,
        );
      },
    );
  }

  Future<void> reactToComment(int commentId, ReactionType type) async {
    await _handleReactionUpdate(
      commentId,
      () => _reactRepo.reactToComment(commentId, type),
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

        if (currentType != null) {
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
  }

  void resetForNewPost() {
    emit(CommentListStateExtensions.initial());
    _currentPostId = null;
  }

  Future<void> fetchComments(int postId, {bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    // Reset state if new post
    if (!loadMore && _currentPostId != postId) {
      emit(CommentListStateExtensions.initial().copyWith(isLoading: true));
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

      final updatedComments = _updateCommentRecursively(
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

      if (_currentPostId != null) {
        await fetchComments(_currentPostId!);
      }

      emit(state.copyWith(isSubmitting: false, resetReplyingTo: true));
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
    if (!state.resetReplyingTo) {
      emit(state.copyWith(resetReplyingTo: true));
    }
  }

  Future<List<String>> uploadMediaFiles(List<File> files) async {
    final urls = await Future.wait(
      files.map(
        (file) => _uploader.uploadFile(file).catchError((e) {
          throw Exception('Upload failed: $e');
        }),
      ),
    );
    return urls;
  }
}
