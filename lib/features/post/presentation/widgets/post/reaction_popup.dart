import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:flutter/material.dart';

class ReactionPopup extends StatefulWidget {
  final void Function(ReactionType reaction) onSelect;

  const ReactionPopup({super.key, required this.onSelect});

  @override
  State<ReactionPopup> createState() => _ReactionPopupState();
}

class _ReactionPopupState extends State<ReactionPopup>
    with SingleTickerProviderStateMixin {
  int? _hoveredIndex;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getScale(int index) {
    if (_hoveredIndex == null) return 1.0;
    if (_hoveredIndex == index) return 1.8;
    if ((index - _hoveredIndex!).abs() == 1) return 1.2;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
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
          children: List.generate(reactions.length, (index) {
            final reaction = reactions[index];
            return GestureDetector(
              onTap: () => widget.onSelect(reaction.type),
              onPanStart: (_) => setState(() => _hoveredIndex = index),
              onPanEnd: (_) => setState(() => _hoveredIndex = null),
              onTapDown: (_) => setState(() => _hoveredIndex = index),
              onTapCancel: () => setState(() => _hoveredIndex = null),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: _getScale(index),
                curve: Curves.easeOutBack,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    reaction.emoji,
                    style: TextStyle(
                      fontSize: 20,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: reaction.color.withOpacity(0.5),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
