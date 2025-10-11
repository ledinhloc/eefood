import 'dart:ui';

import 'package:flutter/material.dart';

enum ReactionType {
  LIKE,
  LOVE,
  WOW,
  SAD,
  ANGRY
}

List<ReactionOption> reactions = [
  ReactionOption(type: ReactionType.LIKE, emoji: '👍', color: Color(0xFFFF6B35)),
  ReactionOption(type: ReactionType.LOVE, emoji: '❤️', color: Color(0xFFF7931E)),
  ReactionOption(type: ReactionType.WOW, emoji: '😮', color: Color(0xFFFFC107)),
  ReactionOption(type: ReactionType.SAD, emoji: '😢', color: Color(0xFF4CAF50)),
  ReactionOption(type: ReactionType.ANGRY, emoji: '😡', color: Colors.redAccent),
];

class ReactionOption {
  final ReactionType type;
  final String emoji;
  final Color color;

  const ReactionOption({
    required this.type,
    required this.emoji,
    required this.color,
  });
}

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