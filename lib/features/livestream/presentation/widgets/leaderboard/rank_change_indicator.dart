import 'package:eefood/features/livestream/data/model/ranked_entry.dart';
import 'package:flutter/material.dart';

class RankChangeIndicator extends StatefulWidget {
  final RankChange change;
  const RankChangeIndicator({super.key, required this.change});

  @override
  State<RankChangeIndicator> createState() => _RankChangeIndicatorState();
}

class _RankChangeIndicatorState extends State<RankChangeIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    if (widget.change == RankChange.up ||
        widget.change == RankChange.newEntry) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(RankChangeIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.change != oldWidget.change) {
      if (widget.change == RankChange.up ||
          widget.change == RankChange.newEntry) {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.change == RankChange.none) return const SizedBox(width: 28);

    if (widget.change == RankChange.up) {
      return ScaleTransition(
        scale: _bounceAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF00E676).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.5),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_upward, color: Color(0xFF00E676), size: 10),
              SizedBox(width: 2),
              Text(
                'UP',
                style: TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.change == RankChange.down) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFFF5252).withValues(alpha: 0.4),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_downward, color: Color(0xFFFF5252), size: 10),
            SizedBox(width: 2),
            Text(
              'DN',
              style: TextStyle(
                color: Color(0xFFFF5252),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.change == RankChange.newEntry) {
      return ScaleTransition(
        scale: _bounceAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'NEW',
            style: TextStyle(
              color: Colors.black,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    return const SizedBox(width: 28);
  }
}
