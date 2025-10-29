import '../../data/models/post_model.dart';

class PostState {
  final bool isLoading;
  final PostModel? post;
  final bool deleted;
  final String? error;

  const PostState({
    required this.isLoading,
    required this.post,
    required this.deleted,
    required this.error,
  });

  factory PostState.initial() => const PostState(
    isLoading: false,
    post: null,
    deleted: false,
    error: null,
  );

  PostState copyWith({
    bool? isLoading,
    PostModel? post,
    bool? deleted,
    String? error,
  }) {
    return PostState(
      isLoading: isLoading ?? this.isLoading,
      post: post ?? this.post,
      deleted: deleted ?? this.deleted,
      error: error,
    );
  }
}
