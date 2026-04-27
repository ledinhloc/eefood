import 'package:dio/dio.dart';
import 'package:eefood/features/profile/data/models/user_height_request.dart';
import 'package:eefood/features/profile/data/models/user_height_response.dart';
import 'package:eefood/features/profile/data/models/user_weight_request.dart';
import 'package:eefood/features/profile/data/models/user_weight_response.dart';
import 'package:eefood/features/profile/domain/repositories/body_metrics_repository.dart';

class BodyMetricsRepositoryImpl implements BodyMetricsRepository {
  final Dio dio;

  BodyMetricsRepositoryImpl({required this.dio});

  static const _basePath = '/v1/users/me';

  @override
  Future<List<UserHeightResponse>> getMyHeights() async {
    try {
      final response = await dio.get('$_basePath/heights');
      final data = (response.data['data'] as List<dynamic>?) ?? [];
      return data
          .map((e) => UserHeightResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (err) {
      throw Exception('Get user heights failed: $err');
    }
  }

  @override
  Future<UserHeightResponse> createMyHeight(UserHeightRequest request) async {
    try {
      final response = await dio.post(
        '$_basePath/heights',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );
      return UserHeightResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Create user height failed: $err');
    }
  }

  @override
  Future<UserHeightResponse> updateMyHeight(
    int heightId,
    UserHeightRequest request,
  ) async {
    try {
      final response = await dio.put(
        '$_basePath/heights/$heightId',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );
      return UserHeightResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Update user height failed: $err');
    }
  }

  @override
  Future<void> deleteMyHeight(int heightId) async {
    try {
      await dio.delete('$_basePath/heights/$heightId');
    } catch (err) {
      throw Exception('Delete user height failed: $err');
    }
  }

  @override
  Future<List<UserWeightResponse>> getMyWeights() async {
    try {
      final response = await dio.get('$_basePath/weights');
      final data = (response.data['data'] as List<dynamic>?) ?? [];
      return data
          .map((e) => UserWeightResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (err) {
      throw Exception('Get user weights failed: $err');
    }
  }

  @override
  Future<UserWeightResponse> createMyWeight(UserWeightRequest request) async {
    try {
      final response = await dio.post(
        '$_basePath/weights',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );
      return UserWeightResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Create user weight failed: $err');
    }
  }

  @override
  Future<UserWeightResponse> updateMyWeight(
    int weightId,
    UserWeightRequest request,
  ) async {
    try {
      final response = await dio.put(
        '$_basePath/weights/$weightId',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );
      return UserWeightResponse.fromJson(response.data['data']);
    } catch (err) {
      throw Exception('Update user weight failed: $err');
    }
  }

  @override
  Future<void> deleteMyWeight(int weightId) async {
    try {
      await dio.delete('$_basePath/weights/$weightId');
    } catch (err) {
      throw Exception('Delete user weight failed: $err');
    }
  }
}
