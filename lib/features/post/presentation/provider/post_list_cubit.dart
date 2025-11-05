import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/domain/repositories/post_reaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../data/repositories/search_repository.dart';
import '../../domain/repositories/post_repository.dart';

class PostListCubit extends Cubit<PostListState> {
  final PostRepository postRepo = getIt<PostRepository>();
  final PostReactionRepository reactionRepo = getIt<PostReactionRepository>();
  final SearchRepository searchRepo = getIt<SearchRepository>();

  PostListCubit()
      : super(
    PostListState(
      posts: [],
      isLoading: false,
      hasMore: true,
      currentPage: 1,
      keyword: null,
      userId: null,
      region: null,
      difficulty: null,
      category: null,
      maxCookTime: null,
      sortBy: 'newest',
      recentKeywords: [],
    ),
  );

  Future<void> loadRecentKeywords() async {
    final recents = await searchRepo.getRecentSearches();
    emit(state.copyWith(recentKeywords: recents));
  }

  Future<void> saveKeyword(String keyword) async {
    await searchRepo.saveSearch(keyword);
    await loadRecentKeywords(); // cập nhật lại danh sách
  }

  Future<void> deleteKeyword(String keyword) async {
    await searchRepo.deleteSearch(keyword);
    await loadRecentKeywords();
  }

  Future<void> clearAllKeywords() async {
    await searchRepo.clearAll();
    emit(state.copyWith(recentKeywords: []));
  }

  Future<void> resetFilters() async {
    emit(
      PostListState(
        posts: [],
        isLoading: false,
        hasMore: true,
        currentPage: 1,
        keyword: null,
        userId: null,
        region: null,
        difficulty: null,
        category: null,
        maxCookTime: null,
        sortBy: 'newest',
        recentKeywords: state.recentKeywords,
      ),
    );
    await fetchPosts(loadMore: false);
  }

  /// Cập nhật filters cục bộ trong state rồi fetch lại từ trang 1
  Future<void> setFilters({
    String? keyword,
    int? userId,
    String? region,
    String? difficulty,
    String? category,
    int? maxCookTime,
    String? sortBy,

    String? mealType,
    String? diet,
  }) async {
    // Reset về trang 1 với filters mới
    emit(
      state.copyWith(
        posts: [],
        isLoading: false,
        hasMore: true,
        currentPage: 1,
        keyword: keyword,
        userId: userId,
        region: region,
        difficulty: difficulty,
        category: category,
        maxCookTime: maxCookTime,
        sortBy: sortBy ?? state.sortBy,
      ),
    );

    // Fetch new data
    await fetchPosts(loadMore: false);
  }

  /// Clear tất cả filters
  Future<void> clearFilters() async {
    emit(
      PostListState(
        posts: [],
        isLoading: false,
        hasMore: true,
        currentPage: 1,
        keyword: null,
        userId: null,
        region: null,
        difficulty: null,
        category: null,
        maxCookTime: null,
        sortBy: 'newest',
        recentKeywords: state.recentKeywords,
      ),
    );
    // fetch new data from page 1
    await fetchPosts(loadMore: false);
  }

  Future<void> reactToPost(int postId, ReactionType reactionType) async {
    try {
      //luu reaction
      await reactionRepo.reactToPost(postId, reactionType);
      //
      final updatePost = await postRepo.getPostById(postId);
      //cap nhat post trong danh sach hien tai
      final updatedPosts = state.posts.map((p) {
        if (p.id == postId) return updatePost;
        return p;
      }).toList();
      emit(state.copyWith(posts: updatedPosts));
    } catch (e) {
      print('Error when reaching to post: ');
    }
  }

  Future<void> removeReaction(int postId) async {
    try {
      //luu reaction
      await reactionRepo.removeReaction(postId);
      //
      final updatePost = await postRepo.getPostById(postId);
      //cap nhat post trong danh sach hien tai
      final updatedPosts = state.posts.map((p) {
        if (p.id == postId) return updatePost;
        return p;
      }).toList();
      emit(state.copyWith(posts: updatedPosts));
    } catch (e) {
      print('Error when reaching to post: ');
    }
  }

  Future<void> fetchPosts({bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    emit(state.copyWith(isLoading: true));

    final nextPage = loadMore ? state.currentPage + 1 : 1;

    try {
      final posts = await postRepo.getAllPosts(
        nextPage,
        10,
        keyword: state.keyword,
        userId: state.userId,
        region: state.region,
        difficulty: state.difficulty,
        category: state.category,
        maxCookTime: state.maxCookTime,
        sortBy: state.sortBy,
      );

      print('Loaded page $nextPage with ${posts.length} posts');

      emit(
        state.copyWith(
          posts: loadMore ? [...state.posts, ...posts] : posts,
          isLoading: false,
          hasMore: posts.length == 10,
          currentPage: nextPage,
        ),
      );
    } catch (e) {
      print('Error fetching posts: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> fetchOwnPost({
    bool loadMore = false,
    required int userId,
  }) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    emit(state.copyWith(isLoading: true));
    final nextPage = loadMore ? state.currentPage + 1 : 1;
    final posts = await postRepo.getAllPosts(
      nextPage,
      10,
      keyword: state.keyword,
      userId: userId,
      region: state.region,
      difficulty: state.difficulty,
    );
    print('next page la : $nextPage');

    emit(
      PostListState(
        posts: loadMore ? [...state.posts, ...posts] : posts,
        isLoading: false,
        hasMore: posts.length == 10,
        currentPage: nextPage,
        keyword: state.keyword,
        userId: state.userId,
        region: state.region,
        difficulty: state.difficulty,
        recentKeywords: state.recentKeywords,
      ),
    );
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
  final String? category;
  final int? maxCookTime;
  final String sortBy;
  final List<String> recentKeywords;

  PostListState({
    required this.posts,
    required this.isLoading,
    required this.hasMore,
    required this.currentPage,
    this.keyword,
    this.userId,
    this.region,
    this.difficulty,
    this.category,
    this.maxCookTime,
    this.sortBy = 'newest',
    this.recentKeywords = const [],
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
    String? category,
    int? maxCookTime,
    String? sortBy,
    List<String>? recentKeywords,
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
      category: category ?? this.category,
      maxCookTime: maxCookTime ?? this.maxCookTime,
      sortBy: sortBy ?? this.sortBy,
      recentKeywords: recentKeywords ?? this.recentKeywords,
    );
  }
}

  /// Check if có filter nào đang active
//   bool get hasActiveFilters => {
//       keyword != null ||
//           userId != null ||
//           region != null ||
//           difficulty != null ||
//           category != null ||
//           maxCookTime != null ||
//           sortBy != 'newest';
// }