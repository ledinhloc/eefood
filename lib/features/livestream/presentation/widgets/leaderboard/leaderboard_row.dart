import 'package:eefood/features/livestream/data/model/ranked_entry.dart';
import 'package:eefood/features/livestream/presentation/widgets/leaderboard/entry_avatar.dart';
import 'package:eefood/features/livestream/presentation/widgets/leaderboard/rank_badge.dart';
import 'package:eefood/features/livestream/presentation/widgets/leaderboard/rank_change_indicator.dart';
import 'package:flutter/material.dart';

class LeaderboardRow extends StatefulWidget {
  final RankedEntry entry;
  final Duration animateDelay;
  const LeaderboardRow({
    super.key,
    required this.entry,
    required this.animateDelay,
  });

  @override
  State<LeaderboardRow> createState() => _LeaderboardRowState();
}

class _LeaderboardRowState extends State<LeaderboardRow>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _flashController;
  late final Animation<double> _slideAnim;
  late final Animation<double> _flashAnim;

  RankChange? _previousChange;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    );
    _flashAnim = CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    );

    Future.delayed(widget.animateDelay, () {
      if (mounted) _slideController.forward();
    });

    _triggerChangeEffect(widget.entry.rankChange);
  }

  @override
  void didUpdateWidget(LeaderboardRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entry.rankChange != _previousChange &&
        widget.entry.rankChange != RankChange.none) {
      _triggerChangeEffect(widget.entry.rankChange);
    }
  }

  void _triggerChangeEffect(RankChange change) {
    _previousChange = change;
    if (change == RankChange.up || change == RankChange.newEntry) {
      _flashController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-0.3, 0),
        end: Offset.zero,
      ).animate(_slideAnim),
      child: FadeTransition(
        opacity: _slideAnim,
        child: AnimatedBuilder(
          animation: _flashAnim,
          builder: (context, child) {
            final flashColor =
                widget.entry.rankChange == RankChange.up ||
                    widget.entry.rankChange == RankChange.newEntry
                ? const Color(
                    0xFFFFD700,
                  ).withValues(alpha: 0.15 * (1 - _flashAnim.value))
                : Colors.transparent;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Color.lerp(
                  _rowBaseColor(widget.entry.rank),
                  flashColor,
                  _flashAnim.value == 0 ? 0 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _rowBorderColor(widget.entry.rank),
                  width: widget.entry.rank <= 3 ? 1.5 : 1,
                ),
              ),
              child: child,
            );
          },
          child: Row(
            children: [
              // Rank badge
              RankBadge(rank: widget.entry.rank),
              const SizedBox(width: 12),
              // Avatar
              EntryAvatar(
                avatarUrl: widget.entry.avatarUrl,
                rank: widget.entry.rank,
              ),
              const SizedBox(width: 10),
              // Name & diamonds
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.username ?? 'Unknown',
                      style: TextStyle(
                        color: widget.entry.rank <= 3
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: widget.entry.rank <= 3
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 3),
                        Text(
                          _formatDiamonds(widget.entry.totalDiamonds ?? 0),
                          style: const TextStyle(
                            color: Color(0xFF7ECFF4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Rank change indicator
              RankChangeIndicator(change: widget.entry.rankChange),
            ],
          ),
        ),
      ),
    );
  }

  Color _rowBaseColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700).withValues(alpha: 0.12);
      case 2:
        return const Color(0xFFC0C0C0).withValues(alpha: 0.09);
      case 3:
        return const Color(0xFFCD7F32).withValues(alpha: 0.09);
      default:
        return const Color(0xFF1A1A2E);
    }
  }

  Color _rowBorderColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700).withValues(alpha: 0.45);
      case 2:
        return const Color(0xFFC0C0C0).withValues(alpha: 0.35);
      case 3:
        return const Color(0xFFCD7F32).withValues(alpha: 0.35);
      default:
        return Colors.white.withValues(alpha: 0.07);
    }
  }

  String _formatDiamonds(num value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}
