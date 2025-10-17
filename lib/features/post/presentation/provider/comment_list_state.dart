import 'package:eefood/features/post/data/models/comment_model.dart';

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