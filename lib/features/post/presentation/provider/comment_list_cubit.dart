import 'dart:io';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/domain/repositories/comment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentListState {
  final List<CommentModel> comments;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;
  final bool isSubmitting;
  final CommentModel? replyingTo;
  final bool resetReplyingTo;
  final int? replyKey;

  CommentListState({
    this.comments = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
    this.isSubmitting = false,
    this.replyingTo,
    this.resetReplyingTo = false,
    this.replyKey = 0,
  });

  CommentListState copyWith({
    List<CommentModel>? comments,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    bool? isSubmitting,
    CommentModel? replyingTo,
    bool resetReplyingTo = false,
    int? replyKey,
  }) {
    return CommentListState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      replyingTo: resetReplyingTo ? null : (replyingTo ?? this.replyingTo),
      replyKey: replyKey ?? this.replyKey,
    );
  }
}

class CommentListCubit extends Cubit<CommentListState> {
  final CommentRepository repository = getIt<CommentRepository>();
  final FileUploader _uploader = getIt<FileUploader>();
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

  void resetForNewPost() {
    emit(
      CommentListState(
        comments: [],
        isLoading: false,
        hasMore: true,
        currentPage: 1,
        replyingTo: null,
      ),
    );
    _currentPostId = null;
  }

  Future<void> fetchComments(int postId, {bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    // Nếu là post khác, reset hoàn toàn state
    if (!loadMore && _currentPostId != postId) {
      emit(
        CommentListState(
          comments: [],
          isLoading: true,
          hasMore: true,
          currentPage: 1,
          replyingTo: null, // Quan trọng: reset replyingTo
        ),
      );
    } else {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }

    _currentPostId = postId;
    final nextPage = loadMore ? state.currentPage + 1 : 1;

    try {
      final comments = await repository.getCommentsByPost(
        postId,
        page: nextPage,
        limit: 5,
      );

      emit(
        state.copyWith(
          comments: loadMore ? [...state.comments, ...comments] : comments,
          isLoading: false,
          hasMore: comments.length == 5,
          currentPage: nextPage,
          replyingTo: loadMore
              ? state.replyingTo
              : null, // Giữ replyingTo khi loadMore
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          replyingTo: null, // Reset replyingTo khi có lỗi
        ),
      );
    }
  }

  Future<void> fetchRepliesComment(
    int parentId, {
    bool loadMore = false,
  }) async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));

    try {
      final newReplies = await repository.getRepliesByComment(
        parentId,
        page: 1,
        limit: 10,
      );

      // Tìm và cập nhật comment có id = parentId
      final updatedComments = _updateCommentWithReplies(
        state.comments,
        parentId,
        newReplies,
      );

      emit(state.copyWith(comments: updatedComments, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  List<CommentModel> _updateCommentWithReplies(
    List<CommentModel> comments,
    int parentId,
    List<CommentModel> newReplies,
  ) {
    return comments.map((comment) {
      // Nếu đây là comment cần update
      if (comment.id == parentId) {
        // Tạo comment mới với replies được cập nhật
        return CommentModel(
          id: comment.id,
          userId: comment.userId,
          parentId: comment.parentId,
          content: comment.content,
          createdAt: comment.createdAt,
          replies: newReplies, // Cập nhật replies mới
          reactionCounts: comment.reactionCounts,
          replyCount: comment.replyCount,
          images: comment.images,
          videos: comment.videos,
          username: comment.username,
          email: comment.email,
          avatarUrl: comment.avatarUrl,
          level: comment.level,
          isRepliesExpanded: comment.isRepliesExpanded,
        );
      }

      // Nếu comment có replies, tìm đệ quy trong replies
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        final updatedReplies = _updateCommentWithReplies(
          comment.replies!,
          parentId,
          newReplies,
        );

        // Tạo comment mới với replies đã được cập nhật
        return CommentModel(
          id: comment.id,
          userId: comment.userId,
          parentId: comment.parentId,
          content: comment.content,
          createdAt: comment.createdAt,
          replies: updatedReplies,
          reactionCounts: comment.reactionCounts,
          replyCount: comment.replyCount,
          images: comment.images,
          videos: comment.videos,
          username: comment.username,
          email: comment.email,
          avatarUrl: comment.avatarUrl,
          level: comment.level,
          isRepliesExpanded: comment.isRepliesExpanded,
        );
      }

      // Comment không có gì thay đổi
      return comment;
    }).toList();
  }

  Future<void> submitComment({
    required int postId,
    int? parentId,
    required String content,
    List<String> images = const [],
    List<String> videos = const [],
  }) async {
    if (state.isSubmitting) return;
    print('Cubit: submitComment called, replyingTo: ${state.replyingTo?.id}');

    emit(state.copyWith(isSubmitting: true));

    try {
      final comment = CommentModel(
        content: content,
        parentId: parentId,
        images: images,
        videos: videos,
      );

      final CommentModel? response = await repository.addComment(
        comment,
        postId,
      );
      emit(state.copyWith(isSubmitting: false, resetReplyingTo: true));

      await fetchComments(postId);
    } catch (e) {
      print('Cubit: error in submitComment, resetting replyingTo');
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
    if (state.replyingTo?.id == comment?.id) {
      emit(state.copyWith(resetReplyingTo: true));
    } else {
      emit(state.copyWith(replyingTo: comment, replyKey: state.replyKey! + 1));
    }
  }

  void cancelReply() {
    if (!state.resetReplyingTo) {
      emit(state.copyWith(resetReplyingTo: true));
    }
  }

  Future<List<String>> uploadMediaFiles(List<File> files) async {
    final urls = <String>[];
    for (final file in files) {
      try {
        final url = await _uploader.uploadFile(file);
        urls.add(url);
      } catch (e) {
        throw Exception('Upload failed: ${e.toString()}');
      }
    }
    return urls;
  }
}
