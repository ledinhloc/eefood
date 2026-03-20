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
            ],
          ),
          const SizedBox(height: 10),
          Text(proposal.text, style: const TextStyle(color: Colors.white70)),
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
      ),
    );
  }
}
