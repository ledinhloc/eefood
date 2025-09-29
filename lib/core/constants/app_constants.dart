import 'package:eefood/features/recipe/domain/entities/recipe.dart';

class AppConstants {
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
