import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/story_collection_model.dart';
import 'package:eefood/features/post/domain/repositories/story_collection_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryCollectionCubit extends Cubit<StoryCollectionState> {
  final StoryCollectionRepository repository =
      getIt<StoryCollectionRepository>();

  StoryCollectionCubit() : super(StoryCollectionState.initial());

  void _safeEmit(StoryCollectionState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> loadCollectionsContainingStory(int storyId) async {
    try {
      _safeEmit(state.copyWith(isLoadingContaining: true));

      final containingCollections = await repository
          .getCollectionsContainingStory(storyId);

      final containingIds = containingCollections
          .map((c) => c.id)
          .whereType<int>()
          .toSet();

      _safeEmit(
        state.copyWith(
          isLoadingContaining: false,
          collectionIdsContainingStory: containingIds,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isLoadingContaining: false,
          error: 'Không thể tải thông tin collection: ${e.toString()}',
        ),
      );
    }
  }

  bool isStoryInCollection(int? collectionId) {
    if (collectionId == null) return false;
    return state.collectionIdsContainingStory.contains(collectionId);
  }

  Future<void> loadCollections(
    int userId, {
    bool loadMore = false,
    int limit = 5,
  }) async {
    // Ngăn load thừa
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    final nextPage = loadMore ? (state.collections.length ~/ limit) + 1 : 1;

    _safeEmit(state.copyWith(isLoading: !loadMore, isLoadingMore: loadMore));

    try {
      final result = await repository.getUserCollections(
        userId,
        page: nextPage,
        limit: limit,
      );

      final updatedCollections = loadMore
          ? [...state.collections, ...result.collections]
          : result.collections;

      _safeEmit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          collections: updatedCollections,
          totalElements: result.totalElements,
          hasMore: updatedCollections.length < result.totalElements,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> createCollection(StoryCollectionModel collection) async {
    try {
      _safeEmit(state.copyWith(isCreating: true));

      final created = await repository.createStoryCollection(collection);

      _safeEmit(
        state.copyWith(
          isCreating: false,
          collections: [created, ...state.collections],
          successMessage: 'Đã tạo danh mục thành công',
        ),
      );
    } catch (e) {
      _safeEmit(state.copyWith(isCreating: false, error: e.toString()));
    }
  }

  Future<void> updateCollection(StoryCollectionModel collection, int id) async {
    try {
      _safeEmit(state.copyWith(isLoading: true));

      final updated = await repository.updateStoryCollection(collection, id);

      final updatedList = state.collections.map((c) {
        return c.id == id ? updated : c;
      }).toList();

      _safeEmit(
        state.copyWith(
          isLoading: false,
          collections: updatedList,
          successMessage: 'Đã cập nhật danh mục',
        ),
      );
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteCollection(int id) async {
    try {
      _safeEmit(state.copyWith(isLoading: true));

      await repository.deleteStoryCollection(id);

      final updatedList = state.collections.where((c) => c.id != id).toList();

      _safeEmit(
        state.copyWith(
          isLoading: false,
          collections: updatedList,
          successMessage: 'Đã xóa danh mục',
        ),
      );
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<bool> addStoryToCollection(int collectionId, int storyId) async {
    try {
      _safeEmit(state.copyWith(isAdding: true));

      await repository.addStoryToCollection(collectionId, storyId);

      final updatedIds = {...state.collectionIdsContainingStory, collectionId};

      _safeEmit(
        state.copyWith(
          isAdding: false,
          collectionIdsContainingStory: updatedIds,
          successMessage: 'Đã thêm story vào danh mục',
        ),
      );
      return true;
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isAdding: false,
          error: 'Không thể thêm story: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  Future<bool> removeStoryFromCollection(int collectionId, int storyId) async {
    try {
      _safeEmit(state.copyWith(isAdding: true));

      await repository.removeStoryToCollection(collectionId, storyId);

      final updatedIds = {...state.collectionIdsContainingStory}
        ..remove(collectionId);

      _safeEmit(
        state.copyWith(
          isAdding: false,
          collectionIdsContainingStory: updatedIds,
          successMessage: 'Đã xóa story khỏi danh mục',
        ),
      );
      return true;
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isAdding: false,
          error: 'Không thể xóa story: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  void clearMessages() {
    _safeEmit(state.copyWith(successMessage: null, error: null));
  }
}

class StoryCollectionState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isCreating;
  final bool isAdding;
  final bool isLoadingContaining;
  final List<StoryCollectionModel> collections;
  final int totalElements;
  final bool hasMore;
  final Set<int> collectionIdsContainingStory;
  final String? error;
  final String? successMessage;

  StoryCollectionState({
    required this.isLoading,
    required this.isLoadingMore,
    required this.isCreating,
    required this.isAdding,
    required this.isLoadingContaining,
    required this.collections,
    required this.totalElements,
    required this.hasMore,
    required this.collectionIdsContainingStory,
    this.error,
    this.successMessage,
  });

  factory StoryCollectionState.initial() => StoryCollectionState(
    isLoading: false,
    isLoadingMore: false,
    isCreating: false,
    isAdding: false,
    isLoadingContaining: false,
    collections: [],
    totalElements: 0,
    hasMore: false,
    collectionIdsContainingStory: {},
  );

  StoryCollectionState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isCreating,
    bool? isAdding,
    bool? isLoadingContaining,
    List<StoryCollectionModel>? collections,
    int? totalElements,
    bool? hasMore,
    Set<int>? collectionIdsContainingStory,
    String? error,
    String? successMessage,
  }) {
    return StoryCollectionState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isCreating: isCreating ?? this.isCreating,
      isAdding: isAdding ?? this.isAdding,
      isLoadingContaining: isLoadingContaining ?? this.isLoadingContaining,
      collections: collections ?? this.collections,
      totalElements: totalElements ?? this.totalElements,
      hasMore: hasMore ?? this.hasMore,
      collectionIdsContainingStory:
          collectionIdsContainingStory ?? this.collectionIdsContainingStory,
      error: error,
      successMessage: successMessage,
    );
  }
}
