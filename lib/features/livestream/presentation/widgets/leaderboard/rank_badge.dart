import 'package:eefood/features/livestream/presentation/widgets/leaderboard/medal_badge.dart';
import 'package:flutter/material.dart';

class RankBadge extends StatelessWidget {
  final int rank;
  const RankBadge({super.key, required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank == 1) {
      return MedalBadge(
        emoji: '🥇',
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
        ),
        size: 36,
      );
    }
    if (rank == 2) {
      return MedalBadge(
        emoji: '🥈',
        gradient: const LinearGradient(
          colors: [Color(0xFFE8E8E8), Color(0xFFA8A8A8)],
        ),
        size: 34,
      );
    }
    if (rank == 3) {
      return MedalBadge(
        emoji: '🥉',
        gradient: const LinearGradient(
          colors: [Color(0xFFE8A96B), Color(0xFFA0522D)],
        ),
        size: 34,
      );
    }

    return SizedBox(
      width: 36,
      child: Text(
        '#$rank',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
