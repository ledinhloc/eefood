import 'package:flutter/material.dart';
import '../../data/model/live_reaction_response.dart';
import '../../../../core/utils/food_emotion_helper.dart';

class LiveReactionAnimation extends StatefulWidget {
  final LiveReactionResponse reaction;
  final VoidCallback onComplete;

  const LiveReactionAnimation({
    Key? key,
    required this.reaction,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<LiveReactionAnimation> createState() => _LiveReactionAnimationState();
}

class _LiveReactionAnimationState extends State<LiveReactionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveUpAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Animation bay lên
    _moveUpAnimation = Tween<double>(
      begin: 0,
      end: -300,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Animation fade out
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ));

    // Animation scale
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          right: 16,
          bottom: 100 + _moveUpAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji
                  Text(
                    FoodEmotionHelper.getEmoji(widget.reaction.emotion),
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FoodEmotionHelper.getColor(widget.reaction.emotion),
                        width: 2,
                      ),
                      image: widget.reaction.avatarUrl.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(widget.reaction.avatarUrl),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: widget.reaction.avatarUrl.isEmpty
                        ? const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}