import '../../data/models/collection_model.dart';

abstract class CollectionRepository {
  Future<List<CollectionModel>> getCollectionsByUser();
  Future<CollectionModel> getCollectionById(int id);
}
