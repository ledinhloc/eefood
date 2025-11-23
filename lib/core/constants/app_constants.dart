import 'package:eefood/features/post/data/models/story_model.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/recipe/domain/entities/recipe.dart';

class AppConstants {
  static final List<UserStoryModel> userStories = [
    UserStoryModel(
      userId: 2,
      username: "Linh",
      avatarUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEus4MjiZTlKETMNxBjXsa_5tGDxLKmzmfJA&s",
      stories: [
        StoryModel(
          id: 1,
          userId: 2,
          type: "image",
          contentUrl:
              "https://hinhcute.net/wp-content/uploads/2025/08/buc-anh-hinh-anh-dep-doc-la-man-hinh-dien-thoai-20-03-2025.jpg",
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          expiredAt: DateTime.now().add(const Duration(hours: 22)),
          isViewed: false,
        ),
        StoryModel(
          id: 5,
          userId: 2,
          type: "image",
          contentUrl:
              "https://dashboard.dienthoaivui.com.vn/uploads/wp-content/uploads/2023/04/6-1.jpg",
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          expiredAt: DateTime.now().add(const Duration(hours: 22)),
          isViewed: false,
        ),
      ],
    ),

    UserStoryModel(
      userId: 3,
      username: "Hoàng",
      avatarUrl:
          "https://cdn2.fptshop.com.vn/unsafe/1920x0/filters:format(webp):quality(75)/avatar_dep_cho_nam_0_d82ba08b05.jpg",
      stories: [
        StoryModel(
          id: 2,
          userId: 3,
          type: "image",
          contentUrl:
              "https://didongviet.vn/dchannel/wp-content/uploads/2023/08/galaxy-hinh-nen-iphone-doc-dep-didongviet@2x-576x1024.jpg",
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          expiredAt: DateTime.now().add(const Duration(hours: 23)),
          isViewed: false,
        ),
      ],
    ),

    UserStoryModel(
      userId: 4,
      username: "Minh",
      avatarUrl:
          "https://cellphones.com.vn/sforum/wp-content/uploads/2024/02/anh-avatar-ngau-2.jpg",
      stories: [
        StoryModel(
          id: 3,
          userId: 4,
          type: "image",
          contentUrl:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSacskkWT_p0fqaj7kcU974igrJX7-RT9hi0g&s",
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          expiredAt: DateTime.now().add(const Duration(hours: 23)),
          isViewed: true,
        ),
      ],
    ),

    UserStoryModel(
      userId: 5,
      username: "Trang",
      avatarUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7BtbWHrJg5Yg5ab9hgKUGaQV3pRRQHYi1oA&s",
      stories: [
        StoryModel(
          id: 4,
          userId: 5,
          type: "image",
          contentUrl:
              "https://cdn2.fptshop.com.vn/unsafe/hinh_nen_iphone_doc_dep_19_561e395f40.jpg",
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          expiredAt: DateTime.now().add(const Duration(hours: 21)),
          isViewed: false,
        ),
      ],
    ),
  ];
  static const List<String> backgroundImages = [
    'https://t4.ftcdn.net/jpg/01/11/77/45/360_F_111774535_GomROlCAeTnMNNI61ESbu00qtCRoQkaX.jpg',
    'https://cdn2.fptshop.com.vn/unsafe/1920x0/filters:format(webp):quality(75)/2024_5_20_638518205896977020_hinh-nen-may-tinh-chill-cover.jpeg',
    'https://cdn.tgdd.vn/Files/2020/06/16/1263495/food_800x450.jpg',
    'https://cdn2.fptshop.com.vn/unsafe/Uploads/images/tin-tuc/184494/Originals/anh-bia-nam-9.jpg',
    'https://24hstore.vn/upload_images/images/anh-bia-facebook-dep/anh-bia-facebook-dep_(1).jpg',
    'https://cdn2.fptshop.com.vn/unsafe/Uploads/images/tin-tuc/184494/Originals/anh-bia-nam-20.jpg',
    'https://cdn2.fptshop.com.vn/unsafe/Uploads/images/tin-tuc/184494/Originals/anh-bia-nam-21.jpg',
  ];
  static const List<String> cookTimes = [
    '5 min',
    '10 min',
    '15 min',
    '20 min',
    '30 min',
    '45 min',
    '1 hour',
    '1 hour 30 min',
    '2 hours',
    '2+ hours',
  ];
  static const List<String> prepTimes = [
    '5 min',
    '10 min',
    '15 min',
    '20 min',
    '30 min',
    '45 min',
    '1 hour',
  ];
  static const Map<Difficulty, String> difficulties = {
    Difficulty.EASY: 'Easy',
    Difficulty.MEDIUM: 'Medium',
    Difficulty.HARD: 'Hard',
  };

  static const diets = [
    {"name": "Ăn chay", "icon": "🥦"},
    {"name": "Thuần chay", "icon": "🌱"},
    {"name": "Ăn cá", "icon": "🐟"},
    {"name": "Không gluten", "icon": "🚫🌾"},
    {"name": "Ít carb", "icon": "🥩"},
    {"name": "Paleo", "icon": "🍖"},
    {"name": "Halal", "icon": "🕌"},
    {"name": "Kosher", "icon": "✡️"},
    {"name": "Không đường", "icon": "🍬"},
    {"name": "Thấp natri", "icon": "🧂"},
    {"name": "Không sữa", "icon": "🥛"},
    {"name": "Eat Clean", "icon": "🥗"},
  ];
  static final allergies = [
    {"name": "Đậu phộng", "icon": "🥜"},
    {"name": "Hạt", "icon": "🌰"},
    {"name": "Sữa bò", "icon": "🥛"},
    {"name": "Trứng gà", "icon": "🥚"},
    {"name": "Lúa mì", "icon": "🌾"},
    {"name": "Đậu nành", "icon": "🫘"},
    {"name": "Cá", "icon": "🐟"},
    {"name": "Tôm cua", "icon": "🦐"},
    {"name": "Vừng/Mè", "icon": "⚪"},
    {"name": "Mắm tôm", "icon": "🟣"},
    {"name": "Ốc, nghêu, sò", "icon": "🐚"},
  ];
  static final cuisines = [
    {"name": "Gỏi/Salad", "icon": "🥗"},
    {"name": "Trứng", "icon": "🍳"},
    {"name": "Canh/Súp", "icon": "🍲"},
    {"name": "Thịt heo/bò", "icon": "🍖"},
    {"name": "Gà", "icon": "🍗"},
    {"name": "Hải sản", "icon": "🦐"},
    {"name": "Bánh mì kẹp", "icon": "🥪"},
    {"name": "Bánh xèo", "icon": "🥞"},
    {"name": "Phở", "icon": "🍜"},
    {"name": "Bún chả", "icon": "🍢"},
    {"name": "Cơm tấm", "icon": "🍚"},
    {"name": "Pizza", "icon": "🍕"},
    {"name": "Sushi", "icon": "🍣"},
  ];
}
