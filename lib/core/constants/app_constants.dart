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
}
