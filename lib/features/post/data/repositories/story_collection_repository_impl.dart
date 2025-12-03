import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/story_collection_model.dart';
import 'package:eefood/features/post/data/models/story_model.dart';
import 'package:eefood/features/post/domain/repositories/story_collection_repository.dart';
import 'package:flutter/material.dart';

class StoryCollectionRepositoryImpl extends StoryCollectionRepository {
  final Dio dio;
  StoryCollectionRepositoryImpl({required this.dio});

  @override
  Future<StoryCollectionModel> createStoryCollection(
    StoryCollectionModel request,
  ) async {
    try {
      final response = await dio.post(
        '/v1/story-collection',
        data: {
          'name': request.name,
          'imageUrl': request.imageUrl,
          'description': request.description,
        },
      );

      if (response.statusCode != 200) {
        throw new Exception('Failed to create story collection');
      } else {
        final data = response.data['data'];
        return StoryCollectionModel.fromJson(data);
      }
    } catch (e) {
      throw new Exception('Failed to create story collection $e');
    }
  }

  @override
  Future<StoryCollectionModel> updateStoryCollection(
    StoryCollectionModel request,
    int id,
  ) async {
    try {
      final response = await dio.put(
        '/v1/story-collection/$id',
        data: {
          'name': request.name,
          'imageUrl': request.imageUrl,
          'description': request.description,
        },
      );

      if (response.statusCode != 200) {
        throw new Exception('Failed to update story collection');
      } else {
        final data = response.data['data'];
        return StoryCollectionModel.fromJson(data);
      }
    } catch (e) {
      throw new Exception('Failed to update story collection $e');
    }
  }

  @override
  Future<void> deleteStoryCollection(int id) async {
    try {
      final response = await dio.delete('/v1/story-collection/$id');
      if (response.statusCode != 200) {
        throw new Exception('Failed to delete story collection');
      }
    } catch (e) {
      throw new Exception('Failed to delete story collection $e');
    }
  }

  @override
  Future<StoryCollectionPageModel> getUserCollections(
    int userId, {
    int page = 1,
    int limit = 5,
  }) async {
    try {
      final response = await dio.get(
        '/v1/story-collection',
        queryParameters: {'userId': userId, 'page': page, 'limit': limit},
      );

      if (response.statusCode != 200) {
        throw new Exception('Failed to get user collection');
      } else {
        final data = response.data['data'];
        return StoryCollectionPageModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Failed to get user collection $e');
      throw new Exception('Failed to get user collection $e');
    }
  }

  @override
  Future<List<StoryModel>> getAllStoryCollections(int collectionId) async {
    try {
      final response = await dio.get('/v1/story-collection/$collectionId');

      if (response.statusCode != 200) {
        throw new Exception('Failed to get user collection');
      } else {
        final data = response.data['data'];
        return data.map((json) => StoryModel.fromJson(json)).toList();
      }
    } catch (e) {
      throw new Exception('Failed to get user collection $e');
    }
  }

  @override
  Future<void> addStoryToCollection(int collectionId, int storyId) async{
    try {
      final response  = await dio.post(
        '/v1/story-collection/$collectionId/story/$storyId'
      );
      if (response.statusCode != 200) {
        throw new Exception('Failed to add story to collection');
      }
    }
    catch(e) {
      throw new Exception('Failed to add story to collection $e');
    }
  }

  @override
  Future<void> removeStoryToCollection(int collectionId, int storyId) async {
    try {
      final response = await dio.delete(
        '/v1/story-collection/$collectionId/story/$storyId',
      );
      if (response.statusCode != 200) {
        throw new Exception('Failed to remove story to collection');
      }
    } catch (e) {
      debugPrint('Failed to remove story to collection $e');
      throw new Exception('Failed to remove story to collection $e');
    }
  }

   @override
  Future<List<StoryCollectionModel>> getCollectionsContainingStory(
    int storyId,
  ) async {
    try {
      final response = await dio.get(
        '/v1/story-collection/containing/$storyId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get collections containing story');
      } else {
        final data = response.data['data'] as List;
        return data.map((json) => StoryCollectionModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to get collections containing story $e');
      throw Exception('Failed to get collections containing story $e');
    }
  }
}
