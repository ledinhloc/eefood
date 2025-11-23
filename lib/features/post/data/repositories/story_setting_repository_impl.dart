import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/story_setting_model.dart';
import 'package:eefood/features/post/domain/repositories/story_setting_repository.dart';

class StorySettingRepositoryImpl extends StorySettingRepository{
  final Dio dio;
  StorySettingRepositoryImpl({required this.dio});

  @override
  Future<StorySettingModel> getSetting(int userId) async {
    try {
      final response = await dio.get(
      '/v1/story/settings/$userId'
    );

    if(response.statusCode != 200) {
      throw new Exception('Failed to fetch settings');
    }
    return StorySettingModel.fromJson(response.data['data']);
    }
    catch(e) {
      throw new Exception('Failed to fetch settings: $e');
    }
  }
}