import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/domain/repositories/post_reaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/repositories/post_repository.dart';

class PostListCubit extends Cubit<PostListState> {
  final PostRepository postRepo = getIt<PostRepository>();
  final PostReactionRepository reactionRepo = getIt<PostReactionRepository>();

  PostListCubit()
      : super(PostListState(posts: [], isLoading: false, hasMore: true, currentPage: 1, keyword: null, userId: null, region: null, difficulty: null));

  Future<void> reactToPost(int postId, ReactionType reactionType) async {
    try{
      //luu reaction
      await reactionRepo.reactToPost(postId, reactionType);
      //
      final updatePost = await postRepo.getPostById(postId);
      //cap nhat post trong danh sach hien tai
      final updatedPosts = state.posts.map((p){
        if(p.id == postId) return updatePost;
        return p;
      }).toList();
      emit(state.copyWith(posts: updatedPosts));
    }catch(e){
      print('Error when reaching to post: ');
    }
  }

  Future<void> removeReaction(int postId) async {
    try{
      //luu reaction
      await reactionRepo.removeReaction(postId);
      //
      final updatePost = await postRepo.getPostById(postId);
      //cap nhat post trong danh sach hien tai
      final updatedPosts = state.posts.map((p){
        if(p.id == postId) return updatePost;
        return p;
      }).toList();
      emit(state.copyWith(posts: updatedPosts));
    }catch(e){
      print('Error when reaching to post: ');
    }
  }

  Future<void> fetchPosts({bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    emit(state.copyWith(isLoading: true));
    final nextPage = loadMore ? state.currentPage + 1 : 1;
    final posts = await postRepo.getAllPosts(
        nextPage,
        10,
      keyword: state.keyword,
      userId: state.userId,
      region: state.region,
      difficulty: state.difficulty,
    );
    print('next page la : $nextPage');

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
  final String? keyword;
  final int? userId;
  final String? region;
  final String? difficulty;
  PostListState({
    required this.posts,
    required this.isLoading,
    required this.hasMore,
    required this.currentPage,
     this.keyword,
     this.userId,
     this.region,
     this.difficulty,
  });

  PostListState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? keyword,
    int? userId,
    String? region,
    String? difficulty,
  }) {
    return PostListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      keyword: keyword ?? this.keyword,
      userId: userId ?? this.userId,
      region: region ?? this.region,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
