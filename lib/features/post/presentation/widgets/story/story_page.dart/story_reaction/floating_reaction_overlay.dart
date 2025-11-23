import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/story_reaction_model.dart';
import 'package:flutter/material.dart';

class FloatingReactionOverlay extends StatefulWidget {
  final List<StoryReactionModel> reactions;

  const FloatingReactionOverlay({super.key, required this.reactions});

  @override
  State<FloatingReactionOverlay> createState() =>
      _FloatingReactionOverlayState();
}

class _FloatingReactionOverlayState extends State<FloatingReactionOverlay> {
  final List<FloatingReactionItem> _activeReactions = [];
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(FloatingReactionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reactions != oldWidget.reactions) {
      _currentIndex = 0;
      _activeReactions.clear();
      _timer?.cancel();
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (widget.reactions.isEmpty) return;

    // Show first 5 reactions immediately, then every 2 seconds
    final firstBatch = widget.reactions.take(5).toList();
    for (var i = 0; i < firstBatch.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) _addReaction(firstBatch[i]);
      });
    }

    _currentIndex = firstBatch.length;

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentIndex < widget.reactions.length) {
        _addReaction(widget.reactions[_currentIndex]);
        _currentIndex++;
      } else {
        timer.cancel();
      }
    });
  }

  void _addReaction(StoryReactionModel reaction) {
    if (!mounted) return;

    final item = FloatingReactionItem(
      key: UniqueKey(),
      reaction: reaction,
      onComplete: () {
        if (mounted) {
          setState(() {
            _activeReactions.removeWhere((r) => r.reaction == reaction);
          });
        }
      },
    );

    setState(() {
      _activeReactions.add(item);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(children: _activeReactions.map((item) => item).toList()),
    );
  }
}

class FloatingReactionItem extends StatefulWidget {
  final StoryReactionModel reaction;
  final VoidCallback onComplete;

  const FloatingReactionItem({
    super.key,
    required this.reaction,
    required this.onComplete,
  });

  @override
  State<FloatingReactionItem> createState() => _FloatingReactionItemState();
}

class _FloatingReactionItemState extends State<FloatingReactionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late double _startX;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Random starting position (left side of screen)
    _startX = 20 + _random.nextDouble() * 60;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    // Floating upward with slight curve
    _slideAnimation = Tween<Offset>(
      begin: Offset(_startX, 0),
      end: Offset(_startX + (_random.nextDouble() * 40 - 20), -400),
    ).animate(CurveTween(curve: Curves.easeOut).animate(_controller));

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
          left: _slideAnimation.value.dx,
          bottom: _slideAnimation.value.dy,
          child: Opacity(opacity: _fadeAnimation.value, child: child!),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: widget.reaction.avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.reaction.avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey.shade700),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade700,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade700,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 4),

          // Reaction emoji
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              ReactionHelper.emoji(widget.reaction.reactionType),
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
