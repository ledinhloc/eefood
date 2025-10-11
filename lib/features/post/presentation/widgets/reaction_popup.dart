import 'package:flutter/material.dart';

import '../../data/models/reaction_type.dart';

class ReactionPopup extends StatelessWidget {
  final void Function(ReactionType reaction) onSelect;

  const ReactionPopup({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
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
    );
  }
}
