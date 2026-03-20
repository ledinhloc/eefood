import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widgets/snack_bar.dart';
import '../../../data/model/live_poll_response.dart';
import '../../../domain/enum/poll_option_proposal_status.dart';
import '../../provider/live_poll_option_proposal_cubit.dart';
import '../../provider/live_poll_option_proposal_state.dart';
import 'poll_option_proposal_item.dart';

class PollOptionProposalSection extends StatefulWidget {
  final LivePollResponse poll;

  const PollOptionProposalSection({super.key, required this.poll});

  @override
  State<PollOptionProposalSection> createState() =>
      _PollOptionProposalSectionState();
}

class _PollOptionProposalSectionState extends State<PollOptionProposalSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LivePollOptionProposalCubit>().init(
        liveStreamId: widget.poll.liveStreamId,
        pollId: widget.poll.id,
      );
    });
  }

  @override
  void didUpdateWidget(covariant PollOptionProposalSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.poll.id != widget.poll.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<LivePollOptionProposalCubit>().init(
          liveStreamId: widget.poll.liveStreamId,
          pollId: widget.poll.id,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      LivePollOptionProposalCubit,
      LivePollOptionProposalState
    >(
      listenWhen: (previous, current) =>
          previous.latestProposal != current.latestProposal ||
          previous.error != current.error,
      listener: (context, state) {
        final latestProposal = state.latestProposal;
        if (latestProposal != null &&
            latestProposal.status == PollOptionProposalStatus.approved) {
          showCustomSnackBar(context, 'Đã chấp nhận đề xuất');
          context.read<LivePollOptionProposalCubit>().clearLatestProposal();
          return;
        }

        if (latestProposal != null &&
            latestProposal.status == PollOptionProposalStatus.rejected) {
          showCustomSnackBar(context, 'Đã từ chối đề xuất');
          context.read<LivePollOptionProposalCubit>().clearLatestProposal();
          return;
        }

        if (state.error != null && state.error!.isNotEmpty) {
          showCustomSnackBar(context, state.error!, isError: true);
          context.read<LivePollOptionProposalCubit>().clearError();
        }
      },
      child:
          BlocBuilder<LivePollOptionProposalCubit, LivePollOptionProposalState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Đề xuất đáp án',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          _ProposalStatusFilter(
                            selectedStatus: state.selectedStatus,
                            onSelected: (status) {
                              context
                                  .read<LivePollOptionProposalCubit>()
                                  .setSelectedStatus(status);
                            },
                          ),
                          const SizedBox(height: 10),
                          if (state.loading && state.proposals.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else if (state.displayedProposals.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C2C2E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _emptyMessage(state.selectedStatus),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            )
                          else
                            Column(
                              children: state.displayedProposals.map((
                                proposal,
                              ) {
                                return PollOptionProposalItem(
                                  key: ValueKey(proposal.id),
                                  proposal: proposal,
                                  poll: widget.poll,
                                  actionLoading: state.actionLoading,
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  String _emptyMessage(PollOptionProposalStatus? status) {
    switch (status) {
      case null:
        return 'Chưa có đề xuất đáp án nào.';
      case PollOptionProposalStatus.pending:
        return 'Chưa có đề xuất nào đang chờ duyệt.';
      case PollOptionProposalStatus.approved:
        return 'Chưa có đề xuất nào đã được chấp nhận.';
      case PollOptionProposalStatus.rejected:
        return 'Chưa có đề xuất nào đã bị từ chối.';
    }
  }
}

class _ProposalStatusFilter extends StatelessWidget {
  final PollOptionProposalStatus? selectedStatus;
  final ValueChanged<PollOptionProposalStatus?> onSelected;

  const _ProposalStatusFilter({
    required this.selectedStatus,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(label: 'Tất cả', value: null),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Chờ duyệt',
            value: PollOptionProposalStatus.pending,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Đã chấp nhận',
            value: PollOptionProposalStatus.approved,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Đã từ chối',
            value: PollOptionProposalStatus.rejected,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required PollOptionProposalStatus? value,
  }) {
    final isSelected = selectedStatus == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: const Color(0xFF2C2C2E),
      selectedColor: Colors.white,
      side: const BorderSide(color: Colors.white12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
