import '../../data/models/collection_model.dart';

abstract class CollectionRepository {
  Future<List<CollectionModel>> getCollectionsByUser();
  Future<CollectionModel> getCollectionById(int id);
  Future<CollectionModel> createCollection(String name);
  Future<CollectionModel> updateCollection(int id, {String? name, String? coverImageUrl});
  Future<void> deleteCollection(int id);
  Future<void> addPostToCollection(int collectionId, int postId);
  Future<void> removePostFromCollection(int collectionId, int postId);
}
