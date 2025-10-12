import 'dart:ui';

import 'package:flutter/material.dart';

enum ReactionType {
  LIKE,
  LOVE,
  WOW,
  SAD,
  ANGRY
}

class ReactionOption {
  final ReactionType type;
  final IconData icon;
  final Color color;

  const ReactionOption({
    required this.type,
    required this.icon,
    required this.color,
  });
}

List<ReactionOption> reactions = [
  ReactionOption(
    type: ReactionType.LIKE,
    icon: Icons.thumb_up_alt_rounded,
    color: const Color(0xFFFF6B35),
  ),
  ReactionOption(
    type: ReactionType.LOVE,
    icon: Icons.favorite_rounded,
    color: const Color(0xFFF44336),
  ),
  ReactionOption(
    type: ReactionType.WOW,
    icon: Icons.emoji_emotions_rounded,
    color: const Color(0xFFFFC107),
  ),
  ReactionOption(
    type: ReactionType.SAD,
    icon: Icons.sentiment_dissatisfied_rounded,
    color: const Color(0xFF4CAF50),
  ),
  ReactionOption(
    type: ReactionType.ANGRY,
    icon: Icons.mood_bad_rounded,
    color: Colors.redAccent,
  ),
];


extension ReactionTypeX on ReactionType {
  String get key => name.toUpperCase(); // ví dụ: "LIKE"

  static ReactionType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'LIKE':
        return ReactionType.LIKE;
      case 'LOVE':
        return ReactionType.LOVE;
      case 'WOW':
        return ReactionType.WOW;
      case 'SAD':
        return ReactionType.SAD;
      case 'ANGRY':
        return ReactionType.ANGRY;
      default:
        return null;
    }
  }
}