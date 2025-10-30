import '../../data/models/post_publish_model.dart';

class PostState {
  final bool isLoading;
  final List<PostPublishModel> posts;
  final bool deleted;
  final String? error;

  const PostState({
    required this.isLoading,
    required this.posts,
    required this.deleted,
    required this.error,
  });

  factory PostState.initial() => const PostState(
    isLoading: false,
    posts: [],
    deleted: false,
    error: null,
  );

  PostState copyWith({
    bool? isLoading,
    List<PostPublishModel>? posts,
    bool? deleted,
    String? error,
  }) {
    return PostState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      deleted: deleted ?? this.deleted,
      error: error,
    );
  }
}
