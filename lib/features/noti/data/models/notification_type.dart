import 'package:flutter/material.dart';

class NotificationType {
  /// Map các loại thông báo chính
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

  /// Map các loại reaction con
  static final Map<String, Map<String, dynamic>> reactionMap = {
    'LIKE': {'icon': Icons.thumb_up_rounded, 'color': Colors.blue},
    'LOVE': {'icon': Icons.favorite_rounded, 'color': Colors.pinkAccent},
    'HAHA': {'icon': Icons.emoji_emotions_rounded, 'color': Colors.amber},
    'WOW': {'icon': Icons.sentiment_very_satisfied_rounded, 'color': Colors.orange},
    'SAD': {'icon': Icons.sentiment_dissatisfied_rounded, 'color': Colors.blueGrey},
    'ANGRY': {'icon': Icons.sentiment_very_dissatisfied_rounded, 'color': Colors.red},
  };

  // Hàm tự phát hiện loại cảm xúc từ nội dung `body`
  static String? detectReactionType(String? body) {
    if (body == null) return null;
    final lower = body.toLowerCase();

    if (lower.contains('haha')) return 'HAHA';
    if (lower.contains('love') || lower.contains('tim') || lower.contains('❤️')) return 'LOVE';
    if (lower.contains('wow')) return 'WOW';
    if (lower.contains('sad') || lower.contains('buồn')) return 'SAD';
    if (lower.contains('angry') || lower.contains('phẫn nộ')) return 'ANGRY';
    if (lower.contains('like') || lower.contains('thích')) return 'LIKE';

    return null;
  }

  /// Lấy icon dựa trên type + body
  static IconData getIcon(String? type, {String? body}) {
    if (type?.toUpperCase() == 'REACTION') {
      final reactionType = detectReactionType(body);
      if (reactionType != null && reactionMap.containsKey(reactionType)) {
        return reactionMap[reactionType]!['icon'];
      }
    }
    return typeMap[type?.toUpperCase()]?['icon'] ?? Icons.notifications_none;
  }

  /// Lấy màu dựa trên type + body
  static Color getColor(String? type, {String? body}) {
    if (type?.toUpperCase() == 'REACTION') {
      final reactionType = detectReactionType(body);
      if (reactionType != null && reactionMap.containsKey(reactionType)) {
        return reactionMap[reactionType]!['color'];
      }
    }
    return typeMap[type?.toUpperCase()]?['color'] ?? Colors.grey;
  }
}
