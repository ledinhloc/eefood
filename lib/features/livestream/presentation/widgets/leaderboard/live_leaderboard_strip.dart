import 'package:eefood/features/livestream/data/model/ranked_entry.dart';
import 'package:eefood/features/livestream/presentation/provider/live_leaderboard_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_leaderboard_state.dart';
import 'package:eefood/features/livestream/presentation/widgets/leaderboard/live_leaderboard_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveLeaderboardStrip extends StatelessWidget {
  final int livestreamId;
  final bool isStreamer;
  const LiveLeaderboardStrip({
    super.key,
    required this.livestreamId,
    required this.isStreamer,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveLeaderboardCubit, LiveLeaderboardState>(
      builder: (context, state) {
        debugPrint(
          '🏆 Strip rebuild: status=${state.status}, entries=${state.entries.length}',
        );
        if (state.isLoading) {
          return _buildSkeleton();
        }
        final top3 = state.entries.take(3).toList();
        if (top3.isEmpty) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => _openFullSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _CrownIcon(),
                const SizedBox(width: 6),
                ...top3.asMap().entries.map(
                  (e) => _TopAvatarChip(entry: e.value, position: e.key),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFullSheet(BuildContext context) {
    final cubit = context.read<LiveLeaderboardCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: LiveLeaderboardSheet(livestreamId: livestreamId),
      ),
    );
  }
}

Widget _buildSkeleton() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _CrownIcon(),
        const SizedBox(width: 6),
        // 3 vòng tròn skeleton mờ
        ...List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ),
        const SizedBox(width: 4),
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.white38,
          ),
        ),
      ],
    ),
  );
}

class _CrownIcon extends StatelessWidget {
  const _CrownIcon();

  @override
  Widget build(BuildContext context) {
    return const Text('👑', style: TextStyle(fontSize: 14));
  }
}

class _TopAvatarChip extends StatelessWidget {
  final RankedEntry entry;
  final int position; // 0-based

  const _TopAvatarChip({required this.entry, required this.position});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: _ringColor(position),
            child: CircleAvatar(
              radius: 12,
              backgroundImage:
                  entry.avatarUrl != null && entry.avatarUrl!.isNotEmpty
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              backgroundColor: Colors.grey[800],
              child: entry.avatarUrl == null || entry.avatarUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 14)
                  : null,
            ),
          ),
          if (entry.rankChange == RankChange.up)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _ringColor(int pos) {
    switch (pos) {
      case 0:
        return const Color(0xFFFFD700);
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return Colors.transparent;
    }
  }
}
