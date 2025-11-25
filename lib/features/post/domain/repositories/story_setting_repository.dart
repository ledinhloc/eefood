import 'package:eefood/features/post/data/models/story_setting_model.dart';

abstract class StorySettingRepository {
  Future<StorySettingModel> getSetting(int userId);
  Future<StorySettingModel> saveSetting(StorySettingModel model);
  Future<void> deletedSetting(int userId);
}
