import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/repositories/post_repository.dart';

class PostListCubit extends Cubit<PostListState> {
  final PostRepository repository = getIt<PostRepository>();
  PostListCubit()
      : super(PostListState(posts: [], isLoading: false, hasMore: true, currentPage: 1));

  Future<void> fetchPosts({bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    emit(state.copyWith(isLoading: true));
    final nextPage = loadMore ? state.currentPage + 1 : 1;
    final posts = await repository.getAllPosts(nextPage, 10);

    emit(PostListState(
      posts: loadMore ? [...state.posts, ...posts] : posts,
      isLoading: false,
      hasMore: posts.length == 10,
      currentPage: nextPage,
    ));
  }
}

class PostListState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;

  PostListState({
    required this.posts,
    required this.isLoading,
    required this.hasMore,
    required this.currentPage,
  });

  PostListState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
  }) {
    return PostListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
