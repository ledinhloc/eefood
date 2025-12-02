import 'dart:io';

import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/domain/repositories/post_reaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/post_model.dart';
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
          recentKeywords: [],
        ),
      );
  void _safeEmit(PostListState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> loadRecentKeywords() async {
    final recents = await searchRepo.getRecentSearches();
    _safeEmit(state.copyWith(recentKeywords: recents));
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
    _safeEmit(state.copyWith(recentKeywords: []));
  }

  /// Clear tất cả filters
  Future<void> resetFilters() async {
    _safeEmit(
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
        recentKeywords: state.recentKeywords,
      ),
    );
    // fetch new data from page 1
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
  }) async {
    // Reset về trang 1 với filters mới
    _safeEmit(
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
      ),
    );

    // Fetch new data
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
      _safeEmit(state.copyWith(posts: updatedPosts));
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
      _safeEmit(state.copyWith(posts: updatedPosts));
    } catch (e) {
      print('Error when reaching to post: ');
    }
  }

  Future<void> fetchPosts({bool loadMore = false, File? imageFile}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    _safeEmit(state.copyWith(isLoading: true));

    final nextPage = loadMore ? state.currentPage + 1 : 1;
    String? keyword = state.keyword;

    try {
      if (imageFile != null) {
        keyword = await postRepo.getKeywordFromImage(imageFile);
      }

      final posts = await postRepo.getAllPosts(
        nextPage,
        10,
        keyword: keyword,
        userId: state.userId,
        region: state.region,
        difficulty: state.difficulty,
        category: state.category,
        maxCookTime: state.maxCookTime,
      );

      print('Loaded page $nextPage with ${posts.length} posts');

      _safeEmit(
        state.copyWith(
          posts: loadMore ? [...state.posts, ...posts] : posts,
          isLoading: false,
          hasMore: posts.length == 10,
          currentPage: nextPage,
          keyword: keyword,
        ),
      );
    } catch (e) {
      print('Error fetching posts: $e');
      _safeEmit(state.copyWith(isLoading: false));
    }
  }

  Future<void> fetchOwnPost({
    bool loadMore = false,
    required int userId,
  }) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;
    if (isClosed) return;
    _safeEmit(state.copyWith(isLoading: true));
    try {
      final nextPage = loadMore ? state.currentPage + 1 : 1;
      final posts = await postRepo.getOwnPosts(nextPage, 10, userId);
      print('${userId}');

      print('Loaded own posts - Page: $nextPage, Count: ${posts.length}');

      _safeEmit(
        state.copyWith(
          posts: loadMore ? [...state.posts, ...posts] : posts,
          isLoading: false,
          hasMore: posts.length == 10,
          currentPage: nextPage,
          userId: userId,
        ),
      );
    } catch (e) {
      print('Error fetching own posts: $e');
      _safeEmit(state.copyWith(isLoading: false));
    }
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
  final List<String> recentKeywords;

  bool hasFilters() {
    return keyword != null ||
        region != null ||
        difficulty != null ||
        category != null ||
        maxCookTime != null;
  }

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
      recentKeywords: recentKeywords ?? this.recentKeywords,
    );
  }
}
