import 'dart:ui';

import 'package:eefood/features/post/data/models/reaction_type.dart';

class ReactionHelper {
  static String emoji(ReactionType? type) {
    if (type == null) return '👍🏻';
    final match = reactions.firstWhere(
      (r) => r.type == type,
      orElse: () => const ReactionOption(
        type: ReactionType.LIKE,
        emoji: '👍',
        color: Color(0xFFFF6B35),
      ),
    );
    return match.emoji;
  }

  static String label(ReactionType? type) {
    switch (type) {
      case ReactionType.LIKE:
        return 'Thích';
      case ReactionType.LOVE:
        return 'Yêu thích';
      case ReactionType.WOW:
        return 'Wow';
      case ReactionType.SAD:
        return 'Buồn';
      case ReactionType.ANGRY:
        return 'Phẫn nộ';
      default:
        return 'Thích';
    }
  }

  static Color color(ReactionType? type) {
    final match = reactions.firstWhere(
      (r) => r.type == type,
      orElse: () => const ReactionOption(
        type: ReactionType.LIKE,
        emoji: '👍',
        color: Color.fromARGB(255, 53, 127, 255),
      ),
    );
    return match.color;
  }
}
