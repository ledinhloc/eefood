import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/story_comment_model.dart';
import 'package:eefood/features/post/domain/repositories/story_comment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryCommentCubit extends Cubit<StoryCommentState> {
  final StoryCommentRepository repository = getIt<StoryCommentRepository>();

  StoryCommentCubit()
    : super(
        StoryCommentState(
          comments: [],
          isLoading: false,
          hasMore: true,
          currentPage: 0,
          totalElements: 0,
          numberOfElements: 0,
          error: null,
          repliesCache: {},
          expandedReplies: {},
          isLoadingReplies: {},
          replyCountCache: {},
        ),
      );

  void _safeEmit(StoryCommentState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  /// Tải danh sách comment cho story
  Future<void> loadComments(int storyId, {bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    _safeEmit(state.copyWith(isLoading: true, error: null));

    try {
      final commentPage = await repository.getComments(storyId);

      // Lấy reply count cho mỗi comment
      final updatedReplyCountCache = Map<int, int>.from(state.replyCountCache);
      for (var comment in commentPage.viewers) {
        if (comment.id != null) {
          try {
            final repliesPage = await repository.getRepliesComments(
              comment.id!,
            );
            updatedReplyCountCache[comment.id!] = repliesPage.totalElements;
          } catch (e) {
            updatedReplyCountCache[comment.id!] = 0;
          }
        }
      }

      _safeEmit(
        state.copyWith(
          storyId: storyId,
          comments: loadMore
              ? [...state.comments, ...commentPage.viewers]
              : commentPage.viewers,
          isLoading: false,
          hasMore: commentPage.viewers.length >= 10,
          currentPage: loadMore ? state.currentPage + 1 : 1,
          totalElements: commentPage.totalElements,
          numberOfElements: commentPage.numberOfElements,
          replyCountCache: updatedReplyCountCache,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(isLoading: false, error: 'Không thể tải bình luận: $e'),
      );
    }
  }

  /// Thêm comment mới
  Future<void> addComment({
    required int storyId,
    required String message,
    int? parentId,
  }) async {
    try {
      final newComment = await repository.addComment(
        storyId,
        message,
        parentId ?? 0,
      );

      if (isClosed) return;

      if (parentId != null) {
        // Nếu là reply, thêm vào replies cache
        await reloadReplies(parentId);
      } else {
        // Nếu là comment chính, thêm vào đầu danh sách
        final updatedComments = [newComment, ...state.comments];

        _safeEmit(
          state.copyWith(
            comments: updatedComments,
            totalElements: state.totalElements + 1,
            numberOfElements: state.numberOfElements + 1,
          ),
        );
      }
    } catch (e) {
      _safeEmit(state.copyWith(error: 'Không thể gửi bình luận: $e'));
      rethrow;
    }
  }

  /// Cập nhật comment
  Future<void> updateComment({
    required int commentId,
    required String message,
  }) async {
    try {
      final updatedComment = await repository.udpateComment(commentId, message);

      if (isClosed) return;

      // Cập nhật comment trong danh sách chính
      final updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          return updatedComment;
        }
        return comment;
      }).toList();

      // Cập nhật comment trong replies cache
      final updatedRepliesCache = Map<int, StoryCommentPage>.from(
        state.repliesCache,
      );

      updatedRepliesCache.forEach((parentId, repliesPage) {
        final updatedReplies = repliesPage.viewers.map((reply) {
          if (reply.id == commentId) {
            return updatedComment;
          }
          return reply;
        }).toList();

        updatedRepliesCache[parentId] = StoryCommentPage(
          viewers: updatedReplies,
          totalElements: repliesPage.totalElements,
          numberOfElements: repliesPage.numberOfElements,
        );
      });

      _safeEmit(
        state.copyWith(
          comments: updatedComments,
          repliesCache: updatedRepliesCache,
        ),
      );
    } catch (e) {
      _safeEmit(state.copyWith(error: 'Không thể cập nhật bình luận: $e'));
      rethrow;
    }
  }

  /// Xóa comment
  Future<void> deleteComment(int commentId, {int? parentId}) async {
     try {
      // Tạo state mới trước khi gọi API để UI cập nhật ngay
      StoryCommentState newState;

      if (parentId != null) {
        // Xóa reply khỏi cache - cập nhật UI ngay lập tức
        final updatedRepliesCache = Map<int, StoryCommentPage>.from(
          state.repliesCache,
        );

        if (updatedRepliesCache.containsKey(parentId)) {
          final repliesPage = updatedRepliesCache[parentId]!;
          final updatedReplies = repliesPage.viewers
              .where((reply) => reply.id != commentId)
              .toList();

          updatedRepliesCache[parentId] = StoryCommentPage(
            viewers: updatedReplies,
            totalElements: repliesPage.totalElements > 0
                ? repliesPage.totalElements - 1
                : 0,
            numberOfElements: repliesPage.numberOfElements > 0
                ? repliesPage.numberOfElements - 1
                : 0,
          );
        }

        // Cập nhật reply count cache
        final updatedReplyCountCache = Map<int, int>.from(
          state.replyCountCache,
        );
        if (updatedReplyCountCache.containsKey(parentId)) {
          final currentCount = updatedReplyCountCache[parentId] ?? 0;
          updatedReplyCountCache[parentId] = currentCount > 0
              ? currentCount - 1
              : 0;
        }

        newState = state.copyWith(
          repliesCache: updatedRepliesCache,
          replyCountCache: updatedReplyCountCache,
        );
      } else {
        // Xóa comment chính khỏi danh sách
        final updatedComments = state.comments
            .where((comment) => comment.id != commentId)
            .toList();

        // Xóa replies cache và expanded state
        final updatedRepliesCache = Map<int, StoryCommentPage>.from(
          state.repliesCache,
        );
        final updatedExpandedReplies = Set<int>.from(state.expandedReplies);
        final updatedReplyCountCache = Map<int, int>.from(
          state.replyCountCache,
        );

        updatedRepliesCache.remove(commentId);
        updatedExpandedReplies.remove(commentId);
        updatedReplyCountCache.remove(commentId);

        newState = state.copyWith(
          comments: updatedComments,
          totalElements: state.totalElements > 0 ? state.totalElements - 1 : 0,
          numberOfElements: state.numberOfElements > 0
              ? state.numberOfElements - 1
              : 0,
          repliesCache: updatedRepliesCache,
          expandedReplies: updatedExpandedReplies,
          replyCountCache: updatedReplyCountCache,
        );
      }
      _safeEmit(newState);

      await repository.deleteComment(commentId);
    } catch (e) {
      if (parentId != null) {
        await reloadReplies(parentId);
      } else {
        await loadComments(state.storyId!);
      }

      _safeEmit(state.copyWith(error: 'Không thể xóa bình luận: $e'));
      rethrow;
    }
  }

  /// Toggle expand/collapse replies
  Future<void> toggleReplies(int parentId) async {
    final updatedExpandedReplies = Set<int>.from(state.expandedReplies);

    if (updatedExpandedReplies.contains(parentId)) {
      // Collapse
      updatedExpandedReplies.remove(parentId);
      _safeEmit(state.copyWith(expandedReplies: updatedExpandedReplies));
    } else {
      // Expand - load replies if not cached
      if (!state.repliesCache.containsKey(parentId)) {
        await loadReplies(parentId);
      } else {
        updatedExpandedReplies.add(parentId);
        _safeEmit(state.copyWith(expandedReplies: updatedExpandedReplies));
      }
    }
  }

  /// Tải replies cho một comment
  Future<void> loadReplies(int parentId, {bool forceReload = false}) async {
    // Nếu đang load, không load lại
    if (state.isLoadingReplies[parentId] == true) return;

    // Nếu đã có cache và không force reload, chỉ expand
    if (state.repliesCache.containsKey(parentId) && !forceReload) {
      final updatedExpandedReplies = Set<int>.from(state.expandedReplies);
      updatedExpandedReplies.add(parentId);
      _safeEmit(state.copyWith(expandedReplies: updatedExpandedReplies));
      return;
    }

    // Set loading state
    final updatedLoadingReplies = Map<int, bool>.from(state.isLoadingReplies);
    updatedLoadingReplies[parentId] = true;
    _safeEmit(state.copyWith(isLoadingReplies: updatedLoadingReplies));

    try {
      final repliesPage = await repository.getRepliesComments(parentId);

      if (isClosed) return;

      final updatedRepliesCache = Map<int, StoryCommentPage>.from(
        state.repliesCache,
      );
      final updatedExpandedReplies = Set<int>.from(state.expandedReplies);
      final updatedLoadingReplies = Map<int, bool>.from(state.isLoadingReplies);

      updatedRepliesCache[parentId] = repliesPage;
      updatedExpandedReplies.add(parentId);
      updatedLoadingReplies[parentId] = false;

      _safeEmit(
        state.copyWith(
          repliesCache: updatedRepliesCache,
          expandedReplies: updatedExpandedReplies,
          isLoadingReplies: updatedLoadingReplies,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      final updatedLoadingReplies = Map<int, bool>.from(state.isLoadingReplies);
      updatedLoadingReplies[parentId] = false;

      _safeEmit(
        state.copyWith(
          error: 'Không thể tải phản hồi: $e',
          isLoadingReplies: updatedLoadingReplies,
        ),
      );
      rethrow;
    }
  }

  /// Reload replies (dùng khi thêm reply mới)
  Future<void> reloadReplies(int parentId) async {
    await loadReplies(parentId, forceReload: true);

    // Cập nhật reply count
    if (state.repliesCache.containsKey(parentId)) {
      final updatedReplyCountCache = Map<int, int>.from(state.replyCountCache);
      updatedReplyCountCache[parentId] =
          state.repliesCache[parentId]!.totalElements;
      _safeEmit(state.copyWith(replyCountCache: updatedReplyCountCache));
    }
  }

  /// Reset state
  void reset() {
    if (isClosed) return;
    _safeEmit(
      StoryCommentState(
        comments: [],
        isLoading: false,
        hasMore: true,
        currentPage: 0,
        totalElements: 0,
        numberOfElements: 0,
        error: null,
        repliesCache: {},
        expandedReplies: {},
        isLoadingReplies: {},
        replyCountCache: {},
      ),
    );
  }
}

class StoryCommentState {
  final int? storyId;
  final List<StoryCommentModel> comments;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final int totalElements;
  final int numberOfElements;
  final String? error;
  final Map<int, StoryCommentPage> repliesCache;
  final Set<int> expandedReplies;
  final Map<int, bool> isLoadingReplies;
  final Map<int, int> replyCountCache; // Lưu số lượng replies cho mỗi comment

  StoryCommentState({
    this.storyId,
    required this.comments,
    required this.isLoading,
    required this.hasMore,
    required this.currentPage,
    required this.totalElements,
    required this.numberOfElements,
    this.error,
    required this.repliesCache,
    required this.expandedReplies,
    required this.isLoadingReplies,
    required this.replyCountCache,
  });

  StoryCommentState copyWith({
    int? storyId,
    List<StoryCommentModel>? comments,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    int? totalElements,
    int? numberOfElements,
    String? error,
    Map<int, StoryCommentPage>? repliesCache,
    Set<int>? expandedReplies,
    Map<int, bool>? isLoadingReplies,
    Map<int, int>? replyCountCache,
  }) {
    return StoryCommentState(
      storyId: storyId ?? this.storyId,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalElements: totalElements ?? this.totalElements,
      numberOfElements: numberOfElements ?? this.numberOfElements,
      error: error,
      repliesCache: repliesCache ?? this.repliesCache,
      expandedReplies: expandedReplies ?? this.expandedReplies,
      isLoadingReplies: isLoadingReplies ?? this.isLoadingReplies,
      replyCountCache: replyCountCache ?? this.replyCountCache,
    );
  }
}
