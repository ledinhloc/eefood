
import 'package:dio/dio.dart';

import '../../domain/repositories/collection_repository.dart';
import '../models/collection_model.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final Dio dio;
  CollectionRepositoryImpl({required this.dio});

  @override
  Future<List<CollectionModel>> getCollectionsByUser() async {
    final res = await dio.get('/v1/collections/user');
    final data = res.data['data'] as List;
    return data.map((e) => CollectionModel.fromJson(e)).toList();
  }
  @override
  Future<CollectionModel> getCollectionById(int id)async {
    final res = await dio.get('/v1/collections/$id');
    return CollectionModel.fromJson(res.data['data']);
  }
}