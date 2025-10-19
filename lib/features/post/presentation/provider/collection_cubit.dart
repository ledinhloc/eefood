import 'package:eefood/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/collection_repository.dart';
import 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  final CollectionRepository repository = getIt<CollectionRepository>();

  CollectionCubit() : super(CollectionState());

  Future<void> fetchCollectionsByUser() async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final collections = await repository.getCollectionsByUser();
      emit(state.copyWith(
        status: CollectionStatus.success,
        collections: collections,
      ));
    } catch (e) {
      emit(state.copyWith(status: CollectionStatus.failure, error: e.toString()));
    }
  }

  Future<void> fetchCollectionDetail(int id) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final collection = await repository.getCollectionById(id);
      emit(state.copyWith(
        status: CollectionStatus.success,
        selectedCollection: collection,
      ));
    } catch (e) {
      emit(state.copyWith(status: CollectionStatus.failure, error: e.toString()));
    }
  }

  Future<void> selectCollectionDetail(int id) async {
    final collection = state.collections.firstWhere(
        (c) => c.id == id
    );
    emit(state.copyWith(selectedCollection: collection, ));
  }

  Future<void> createCollection(String name) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final newCollection = await repository.createCollection(name);
      final updatedCollections = [...state.collections, newCollection];
      emit(state.copyWith(
        status: CollectionStatus.success,
        collections: updatedCollections,
      ));
    } catch (e) {
      emit(state.copyWith(status: CollectionStatus.failure, error: e.toString()));
    }
  }

  Future<void> updateCollection(int id, {String? name, String? coverImageUrl}) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      final updatedCollection = await repository.updateCollection(id, name: name, coverImageUrl: coverImageUrl);
      final updatedCollections = state.collections.map((c) => c.id == id ? updatedCollection : c).toList();
      emit(state.copyWith(
        status: CollectionStatus.success,
        collections: updatedCollections,
        selectedCollection: state.selectedCollection?.id == id ? updatedCollection : state.selectedCollection,
      ));
    } catch (e) {
      emit(state.copyWith(status: CollectionStatus.failure, error: e.toString()));
    }
  }

  Future<void> deleteCollection(int id) async {
    emit(state.copyWith(status: CollectionStatus.loading));
    try {
      await repository.deleteCollection(id);
      final updatedCollections = state.collections.where((c) => c.id != id).toList();
      emit(state.copyWith(
        status: CollectionStatus.success,
        collections: updatedCollections,
        selectedCollection: state.selectedCollection?.id == id ? null : state.selectedCollection,
      ));
    } catch (e) {
      emit(state.copyWith(status: CollectionStatus.failure, error: e.toString()));
    }
  }

  Future<void> addPostToCollection(int collectionId, int postId) async {
    try {
      await repository.addPostToCollection(collectionId, postId);
      await fetchCollectionDetail(collectionId);
    } catch (e) {
      emit(state.copyWith(status: CollectionStatus.failure, error: e.toString()));
    }
  }

  Future<void> removePostFromCollection(int collectionId, int postId) async {
    try {
      await repository.removePostFromCollection(collectionId, postId);
      await fetchCollectionDetail(collectionId);
    } catch (e) {
      emit(state.copyWith(status: CollectionStatus.failure, error: e.toString()));
    }
  }
}
