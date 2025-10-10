import 'package:flutter/material.dart';
class NotificationType {
  static final Map<String, Map<String, dynamic>> typeMap = {
    'COMMENT': {
      'icon': Icons.mode_comment_rounded,
      'color': Colors.blue,
    },
    'REACTION': {
      'icon': Icons.favorite_rounded,
      'color': Colors.pinkAccent,
    },
    'FOLLOW': {
      'icon': Icons.person_add_rounded,
      'color': Colors.green,
    },
    'SYSTEM': {
      'icon': Icons.notifications_active_rounded,
      'color': Colors.orange,
    },
    'SAVE_RECIPE': {
      'icon': Icons.bookmark_rounded,
      'color': Colors.teal,
    },
    'SHARE_RECIPE': {
      'icon': Icons.share_rounded,
      'color': Colors.indigo,
    },
    'WELCOME': {
      'icon': Icons.waving_hand_rounded,
      'color': Colors.amber,
    },
    'RECIPE_OF_THE_DAY': {
      'icon': Icons.local_dining_rounded,
      'color': Colors.deepPurple,
    },
  };

  static IconData getIcon(String? type) {
    return typeMap[type?.toUpperCase()]?['icon'] ?? Icons.notifications_none;
  }

  static Color getColor(String? type) {
    return typeMap[type?.toUpperCase()]?['color'] ?? Colors.grey;
  }
}
