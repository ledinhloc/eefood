import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/story_setting_model.dart';
import 'package:eefood/features/post/domain/repositories/story_setting_repository.dart';

class StorySettingRepositoryImpl extends StorySettingRepository {
  final Dio dio;
  StorySettingRepositoryImpl({required this.dio});

  @override
  Future<StorySettingModel> getSetting(int userId) async {
    try {
      final response = await dio.get('/v1/story/settings/$userId');

      if (response.statusCode != 200) {
        throw new Exception('Failed to fetch settings');
      }
      return StorySettingModel.fromJson(response.data['data']);
    } catch (e) {
      throw new Exception('Failed to fetch settings: $e');
    }
  }

  @override
  Future<StorySettingModel> saveSetting(StorySettingModel model) async {
    try {
      final response = await dio.post(
        '/v1/story/settings',
        data: {
          'userId': model.userId,
          'mode': model.mode.name,
          'allowedUserIds': model.allowedUserIds,
          'blockedUserIds': model.blockedUserIds,
        },
      );

      if (response.statusCode != 200) {
        throw new Exception('${response.statusMessage}');
      }
      return StorySettingModel.fromJson(response.data['data']);
    } catch (e) {
      throw new Exception('Failed to save story settings $e');
    }
  }

  @override
  Future<void> deletedSetting(int userId) async {
    try {
      final response = await dio.delete('/v1/story/settings/$userId');
      if (response.statusCode != 200 && response.statusMessage == null) {
        throw new Exception('Failed to deleted setting');
      }
    } catch (e) {
      throw new Exception('Failed to deleted setting $e');
    }
  }
}
