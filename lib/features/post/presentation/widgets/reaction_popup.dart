import 'package:flutter/material.dart';

enum ReactionType { like, love, wow, sad, angry }
class ReactionOption {
  final ReactionType type;
  final String emoji;
  final String label;
  final Color color;

  const ReactionOption({
    required this.type,
    required this.emoji,
    required this.label,
    required this.color,
  });
}

class ReactionPopup extends StatelessWidget {
  final void Function(ReactionType reaction) onSelect;

  const ReactionPopup({super.key, required this.onSelect});

  static const List<ReactionOption> _reactions = [
    ReactionOption(
        type: ReactionType.like,
        emoji: '👍',
        label: 'Like',
        color: Colors.blue),
    ReactionOption(
        type: ReactionType.love,
        emoji: '❤️',
        label: 'Love',
        color: Colors.red),
    ReactionOption(
        type: ReactionType.wow,
        emoji: '😮',
        label: 'Wow',
        color: Colors.amber),
    ReactionOption(
        type: ReactionType.sad,
        emoji: '😢',
        label: 'Sad',
        color: Colors.lightBlue),
    ReactionOption(
        type: ReactionType.angry,
        emoji: '😡',
        label: 'Angry',
        color: Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _reactions.map((reaction) {
          return GestureDetector(
            onTap: () => onSelect(reaction.type),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reaction.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reaction.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: reaction.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
