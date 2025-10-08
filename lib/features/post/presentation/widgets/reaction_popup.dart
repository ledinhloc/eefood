import 'package:flutter/material.dart';

enum ReactionType { like, love, wow, sad, angry }

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

class ReactionPopup extends StatelessWidget {
  final void Function(ReactionType reaction) onSelect;

  const ReactionPopup({super.key, required this.onSelect});

  static const List<ReactionOption> reactions = [
    ReactionOption(type: ReactionType.like, emoji: '👍', color: Color(0xFFFF6B35)),
    ReactionOption(type: ReactionType.love, emoji: '❤️', color: Color(0xFFF7931E)),
    ReactionOption(type: ReactionType.wow, emoji: '😮', color: Color(0xFFFFC107)),
    ReactionOption(type: ReactionType.sad, emoji: '😢', color: Color(0xFF4CAF50)),
    ReactionOption(type: ReactionType.angry, emoji: '😡', color: Colors.redAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft, // 👈 Căn sát bên trái
      child: Container(
        margin: const EdgeInsets.only(left: 12, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: reactions.map((reaction) {
            return GestureDetector(
              onTap: () => onSelect(reaction.type),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  reaction.emoji,
                  style: TextStyle(
                    fontSize: 30,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: reaction.color.withOpacity(0.4),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
