import 'package:flutter/material.dart';
import '../../features/livestream/data/model/live_reaction_response.dart';

class FoodEmotionHelper {
  static String getEmoji(FoodEmotion emotion) {
    switch (emotion) {
      case FoodEmotion.DELICIOUS:
        return '😋';
      case FoodEmotion.LOVE_IT:
        return '❤️';
      case FoodEmotion.DROOLING:
        return '🤤';
      case FoodEmotion.BAD:
        return '😖';
      case FoodEmotion.NOT_GOOD:
        return '👎';
    }
  }

  static String getLabel(FoodEmotion emotion) {
    switch (emotion) {
      case FoodEmotion.DELICIOUS:
        return 'Ngon';
      case FoodEmotion.LOVE_IT:
        return 'Yêu thích';
      case FoodEmotion.DROOLING:
        return 'Chảy nước miếng';
      case FoodEmotion.BAD:
        return 'Tệ';
      case FoodEmotion.NOT_GOOD:
        return 'Không ngon';
    }
  }

  static Color getColor(FoodEmotion emotion) {
    switch (emotion) {
      case FoodEmotion.DELICIOUS:
        return Colors.orange;
      case FoodEmotion.LOVE_IT:
        return Colors.red;
      case FoodEmotion.DROOLING:
        return Colors.yellow;
      case FoodEmotion.BAD:
        return Colors.grey;
      case FoodEmotion.NOT_GOOD:
        return Colors.brown;
    }
  }
}