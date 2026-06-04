import 'package:eefood/features/livestream/data/model/ranked_entry.dart';
import 'package:eefood/features/livestream/presentation/provider/live_leaderboard_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_leaderboard_state.dart';
import 'package:eefood/features/livestream/presentation/widgets/leaderboard/empty_leaderboard.dart';
import 'package:eefood/features/livestream/presentation/widgets/leaderboard/leaderboard_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveLeaderboardSheet extends StatelessWidget {
  final int livestreamId;
  const LiveLeaderboardSheet({super.key, required this.livestreamId});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D0D1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _SheetHandle(),
              _SheetHeader(),
              Expanded(
                child: BlocBuilder<LiveLeaderboardCubit, LiveLeaderboardState>(
                  builder: (context, state) {
                    if (state.status == LeaderboardStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD700),
                        ),
                      );
                    }
                    if (state.entries.isEmpty) {
                      return EmptyLeaderboard();
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: state.entries.length,
                      itemBuilder: (context, index) {
                        final entry = state.entries[index];
                        return LeaderboardRow(
                          key: ValueKey(entry.userId),
                          entry: entry,
                          animateDelay: Duration(milliseconds: index * 60),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          const Text('👑', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          const Text(
            'Bảng xếp hạng ủng hộ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
