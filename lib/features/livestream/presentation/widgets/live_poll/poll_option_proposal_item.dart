import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/live_poll_option_proposal_response.dart';
import '../../../data/model/live_poll_response.dart';
import '../../../domain/enum/poll_option_proposal_status.dart';
import '../../provider/live_poll_option_proposal_cubit.dart';

class PollOptionProposalItem extends StatelessWidget {
  final LivePollOptionProposalResponse proposal;
  final LivePollResponse poll;
  final bool actionLoading;

  const PollOptionProposalItem({
    super.key,
    required this.proposal,
    required this.poll,
    required this.actionLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[700],
                backgroundImage:
                    proposal.avatarUrl != null && proposal.avatarUrl!.isNotEmpty
                    ? NetworkImage(proposal.avatarUrl!)
                    : null,
                child: proposal.avatarUrl == null || proposal.avatarUrl!.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.username ?? 'Người dùng',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (proposal.email != null &&
                        proposal.email!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        proposal.email!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ProposalStatusBadge(status: proposal.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(proposal.text, style: const TextStyle(color: Colors.white70)),
          if (proposal.status == PollOptionProposalStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: actionLoading
                        ? null
                        : () => context
                              .read<LivePollOptionProposalCubit>()
                              .updateOptionProposalStatus(
                                liveStreamId: poll.liveStreamId,
                                pollId: poll.id,
                                proposalId: proposal.id,
                                status: PollOptionProposalStatus.rejected,
                              ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: actionLoading
                        ? null
                        : () => context
                              .read<LivePollOptionProposalCubit>()
                              .updateOptionProposalStatus(
                                liveStreamId: poll.liveStreamId,
                                pollId: poll.id,
                                proposalId: proposal.id,
                                status: PollOptionProposalStatus.approved,
                              ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: actionLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Chấp nhận'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProposalStatusBadge extends StatelessWidget {
  final PollOptionProposalStatus status;

  const _ProposalStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case PollOptionProposalStatus.pending:
        return 'Chờ duyệt';
      case PollOptionProposalStatus.approved:
        return 'Đã chấp nhận';
      case PollOptionProposalStatus.rejected:
        return 'Đã từ chối';
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case PollOptionProposalStatus.pending:
        return Colors.orange.withValues(alpha: 0.22);
      case PollOptionProposalStatus.approved:
        return Colors.green.withValues(alpha: 0.22);
      case PollOptionProposalStatus.rejected:
        return Colors.red.withValues(alpha: 0.22);
    }
  }

  Color get _foregroundColor {
    switch (status) {
      case PollOptionProposalStatus.pending:
        return Colors.orange.shade200;
      case PollOptionProposalStatus.approved:
        return Colors.green.shade200;
      case PollOptionProposalStatus.rejected:
        return Colors.red.shade200;
    }
  }
}
