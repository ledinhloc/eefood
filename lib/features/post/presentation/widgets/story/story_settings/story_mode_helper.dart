import 'package:eefood/features/post/data/models/story_setting_model.dart';

class StoryModeHelpers {
  static String getTitle(StoryMode mode) {
    switch (mode) {
      case StoryMode.FOLLOWING_ONLY:
        return 'Mặc định (Người theo dõi)';
      case StoryMode.PRIVATE:
        return 'Riêng tư';
      case StoryMode.CUSTOM_INCLUDE:
        return 'Một vài người';
      case StoryMode.BLACKLIST:
        return 'Danh sách chặn';
    }
  }

  static String getDescription(StoryMode mode) {
    switch (mode) {
      case StoryMode.FOLLOWING_ONLY:
        return 'Tất cả người theo dõi bạn có thể xem';
      case StoryMode.PRIVATE:
        return 'Chỉ mình bạn có thể xem';
      case StoryMode.CUSTOM_INCLUDE:
        return 'Chỉ những người bạn chọn có thể xem';
      case StoryMode.BLACKLIST:
        return 'Ẩn tin với những người bạn chọn';
    }
  }
}
