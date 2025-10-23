
import 'package:dio/dio.dart';

import '../../domain/repositories/collection_repository.dart';
import '../models/collection_model.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final Dio dio;
  CollectionRepositoryImpl({required this.dio});

  @override
  Future<void> updatePostCollections(int postId, List<int> collectionIds) async {
    await dio.put(
      '/v1/collections/posts',
      data: {
        'postId': postId,
        'collectionIds': collectionIds,
      },
    );
  }
  @override
  Future<List<CollectionModel>> getCollectionsByUser() async {
    final res = await dio.get('/v1/collections/user');
    final data = res.data['data'] as List;
    return data.map((e) => CollectionModel.fromJson(e)).toList();
  }
  
  @override
  Future<CollectionModel> getCollectionById(int id) async {
    final res = await dio.get('/v1/collections/$id');
    return CollectionModel.fromJson(res.data['data']);
  }

  @override
  Future<CollectionModel> createCollection(String name) async {
    final res = await dio.post('/v1/collections', queryParameters: {'name': name});
    return CollectionModel.fromJson(res.data['data']);
  }

  @override
  Future<CollectionModel> updateCollection(int id, {String? name, String? coverImageUrl}) async {
    final queryParams = <String, dynamic>{};
    if (name != null) queryParams['name'] = name;
    if (coverImageUrl != null) queryParams['coverImageUrl'] = coverImageUrl;
    
    final res = await dio.put('/v1/collections/$id', queryParameters: queryParams);
    return CollectionModel.fromJson(res.data['data']);
  }

  @override
  Future<void> deleteCollection(int id) async {
    await dio.delete('/v1/collections/$id');
  }

  @override
  Future<void> addPostToCollection(int collectionId, int postId) async {
    await dio.post('/v1/collections/$collectionId/posts/$postId');
  }

  @override
  Future<void> removePostFromCollection(int collectionId, int postId) async {
    await dio.delete('/v1/collections/$collectionId/posts/$postId');
  }
}