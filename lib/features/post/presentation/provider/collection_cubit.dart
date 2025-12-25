import 'package:dio/dio.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/collection_repository.dart';
import 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  final CollectionRepository repository = getIt<CollectionRepository>();
  CollectionCubit() : super(CollectionState());

  Future<void> updatePostCollections(
    int postId,
    List<int> collectionIds,
  ) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      await repository.updatePostCollections(postId, collectionIds);
      //refresh danh sach
      await fetchCollectionsByUser();
      // emit(state.copyWith(status: CollectionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: CollectionStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> fetchCollectionsByUser() async {
    if (isClosed) return;
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final collections = await repository.getCollectionsByUser();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CollectionStatus.success,
          collections: collections,
        ),
      );
    } catch (e) {
      if(isClosed) return;
      if (e is DioError && e.response?.statusCode == 401) {
        // Guest: return empty collections silently
        emit(
          state.copyWith(status: CollectionStatus.success, collections: []),
        );
        return;
      }
      emit(
        state.copyWith(status: CollectionStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> fetchCollectionDetail(int id) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final collection = await repository.getCollectionById(id);

      final updatedCollections = state.collections.map((c) {
        return c.id == id ? collection : c;
      }).toList();

      emit(
        state.copyWith(
          status: CollectionStatus.success,
          collections: updatedCollections,
          selectedCollection: collection,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CollectionStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> selectCollectionDetail(int id) async {
    final collection = state.collections.firstWhere((c) => c.id == id);
    emit(state.copyWith(selectedCollection: collection));
  }

  Future<void> createCollection(String name) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final newCollection = await repository.createCollection(name);
      // await fetchCollectionsByUser();
      final updatedCollections = [...state.collections, newCollection];
      emit(
        state.copyWith(
          status: CollectionStatus.success,
          collections: updatedCollections,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CollectionStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> updateCollection(
    int id, {
    String? name,
    String? coverImageUrl,
  }) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final updatedCollection = await repository.updateCollection(
        id,
        name: name,
        coverImageUrl: coverImageUrl,
      );
       // await fetchCollectionDetail(id);
      // // cập nhật danh sách tổng
      final updatedCollections = state.collections.map((c) {
        return c.id == id ? updatedCollection : c;
      }).toList();

      //cập nhật selectedCollection nếu đang xem nó
      final updatedSelected = state.selectedCollection?.id == id
          ? updatedCollection
          : state.selectedCollection;

      emit(state.copyWith(
        status: CollectionStatus.success,
        collections: updatedCollections,
        selectedCollection: updatedSelected,
      ));
    } catch (e) {
      emit(
        state.copyWith(status: CollectionStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> deleteCollection(int id) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      await repository.deleteCollection(id);
      await fetchCollectionsByUser();
      // final updatedCollections = state.collections.where((c) => c.id != id).toList();
      // emit(state.copyWith(
      //   status: CollectionStatus.success,
      //   collections: updatedCollections,
      //   selectedCollection: state.selectedCollection?.id == id ? null : state.selectedCollection,
      // ));
    } catch (e) {
      emit(
        state.copyWith(status: CollectionStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> addPostToCollection(int collectionId, int postId) async {
    try {
      await repository.addPostToCollection(collectionId, postId);
      // await fetchCollectionDetail(collectionId);
      await fetchCollectionsByUser();
    } catch (e) {
      emit(
        state.copyWith(status: CollectionStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> removePostFromCollection(int collectionId, int postId) async {
    try {
      await repository.removePostFromCollection(collectionId, postId);
      await fetchCollectionDetail(collectionId);
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 401) {
        return;
      }
      emit(
        state.copyWith(status: CollectionStatus.failure, error: e.toString()),
      );
    }
  }
}
