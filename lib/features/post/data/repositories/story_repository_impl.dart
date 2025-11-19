import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/story_model.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/post/domain/repositories/story_repository.dart';
import 'package:flutter/widgets.dart';

class StoryRepositoryImpl extends StoryRepository {
  final Dio dio;
  StoryRepositoryImpl({required this.dio});

  @override
  Future<UserStoryModel> getOwnStory() async {
    try {
      final response = await dio.get('/v1/story/me');

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data == null) {
          throw Exception("Story data is null");
        }

        debugPrint("Own Story: $data");

        return UserStoryModel.fromJson(data);
      }

      throw Exception("Invalid response");
    } catch (err) {
      throw Exception('Failed to load own story: $err');
    }
  }

  @override
  Future<List<UserStoryModel>> getFeed(int viewerId) async {
    try {
      final response = await dio.get('/v1/story/$viewerId');

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data == null || data is! List) {
          return List.empty();
        }

        debugPrint("Story Feed: $data");

        return data
            .map<UserStoryModel>((json) => UserStoryModel.fromJson(json))
            .toList();
      }

      return List.empty();
    } catch (err) {
      throw Exception('Failed to load feed story: $err');
    }
  }

  @override
  Future<void> markViewStory(int storyId, int viewerId) async {
    try {
      final response = await dio.post(
        '/v1/story/view',
        data: {"storyId": storyId, "viewerId": viewerId},
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to mark story as viewed");
      }
    } catch (err) {
      throw Exception('Failed to mark view story: $err');
    }
  }

  @override
  Future<StoryModel> createStory(StoryModel request) async {
    try {
      final response = await dio.post(
        '/v1/story',
        data: {
          "userId": request.userId,
          "type": request.type,
          "contentUrl": request.contentUrl,
        },
        options: Options(sendTimeout: const Duration(seconds: 15)),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to create story");
      } else {
        final data = response.data['data'];
        return data;
      }
    } catch (err) {
      throw Exception('Error: $err');
    }
  }

  @override
  Future<StoryModel> updateStory(StoryModel request) async {
    try {
      final response = await dio.put(
        '/v1/story',
        data: {
          "id": request.id,
          "userId": request.userId,
          "type": request.type,
          "contentUrl": request.contentUrl,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update story");
      } else {
        final data = response.data['data'];
        return data;
      }
    } catch (err) {
      throw Exception('Error: $err');
    }
  }

  @override
  Future<void> deleteStory(int id) async {
    try {
      final response = await dio.delete('/v1/story/$id');

      if (response.statusCode != 200) {
        throw Exception("Failed to deleted story");
      }
    } catch (err) {
      throw Exception('Error: $err');
    }
  }
}
