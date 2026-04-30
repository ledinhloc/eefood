import 'package:dio/dio.dart';
import 'package:eefood/features/cook_process/data/models/cooking_session_progress_response.dart';
import 'package:eefood/features/cook_process/data/models/cooking_session_response.dart';
import 'package:eefood/features/cook_process/domain/repositories/cooking_session_repository.dart';

class CookingSessionRepositoryImpl extends CookingSessionRepository {
  final Dio dio;

  CookingSessionRepositoryImpl({required this.dio});

  @override
  Future<bool> isCompleted(int recipeId) async {
    try {
      final response = await dio.get('/v1/cooking/recipe/$recipeId/completed');

      final json = response.data;
      final data = json['data'];
      
      return data;
    } catch (err) {
      throw Exception('Failed get is completed: $err');
    }
  }

  @override
  Future<CookingSessionResponse?> getOrCreateCookingSession(
    int recipeId,
  ) async {
    try {
      final response = await dio.get('/v1/cooking/recipe/$recipeId');

      final json = response.data;

      if (json == null || json['data'] == null) {
        return null;
      }
      return CookingSessionResponse.fromJson(json['data']);
    } catch (err) {
      throw Exception('Failed get cooking session: $err');
    }
  }

  @override
  Future<CookingSessionProgressResponse?> saveProgress(
    int sessionId,
    int currentStep,
  ) async {
    try {
      final response = await dio.put(
        '/v1/cooking/$sessionId/progress',
        data: {'currentStep': currentStep},
      );

      final json = response.data;

      if (json == null || json['data'] == null) {
        return null;
      }
      return CookingSessionProgressResponse.fromJson(json['data']);
    } catch (err) {
      throw Exception('Faield save process: $err');
    }
  }

  @override
  Future<CookingSessionProgressResponse?> completeSession(
    int sessionId
  ) async {
    try {
      final response = await dio.put(
        '/v1/cooking/$sessionId/complete'
      );

      final json = response.data;

      if (json == null || json['data'] == null) {
        return null;
      }
      return CookingSessionProgressResponse.fromJson(json['data']);
    } catch (err) {
      throw Exception('Faield save process: $err');
    }
  }
}
