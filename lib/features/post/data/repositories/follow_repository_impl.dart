import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/follow_model.dart';
import 'package:eefood/features/post/domain/repositories/follow_repository.dart';

class FollowRepositoryImpl extends FollowRepository {
  final Dio dio;
  FollowRepositoryImpl({required this.dio});

  @override
  Future<bool> unFollow(int targetId) async {
    try {
      final response = await dio.delete('/v1/follows/$targetId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data;
      }
      return false;
    } catch (err) {
      throw Exception('Failed: $err');
    }
  }

  @override
  Future<bool> toggleFollow(int targetId) async {
    try {
      final response = await dio.post('/v1/follows/$targetId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data;
      }
      return false;
    } catch (err) {
      throw Exception('Failed: $err');
    }
  }

  @override
  Future<bool> checkFollow(int targetId) async {
    try {
      final response = await dio.get('/v1/follows/check/$targetId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data;
      }
      return false;
    } catch (err) {
      throw Exception('Failed: $err');
    }
  }

  @override
  Future<List<FollowModel>> getFollowers(int userId, int page, int size) async {
    final response = await dio.get(
      '/v1/follows/followers/$userId',
      queryParameters: {'page': page, 'size': size},
    );
    if (response.statusCode == 200) {
      final data = response.data['data'];
      final content = data['content'] as List<dynamic>;
      return content.map((json) => FollowModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<List<FollowModel>> getFollowings(
    int userId,
    int page,
    int size,
  ) async {
    final response = await dio.get(
      '/v1/follows/followings/$userId',
      queryParameters: {'page': page, 'size': size},
    );
    if (response.statusCode == 200) {
      final data = response.data['data'];
      final content = data['content'] as List<dynamic>;
      return content.map((json) => FollowModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Map<String, int>> getFollowStats(int userId) async {
    try {
      final response = await dio.get('/v1/follows/stats/$userId');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return {
          'followers': data['followers'] as int,
          'followings': data['followings'] as int,
        };
      }
      throw Exception('Failed to load follow stats');
    } catch (err) {
      throw Exception('Failed to get follow stats: $err');
    }
  }
}
