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
                      child: state.loading && state.proposals.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : state.proposals.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C2C2E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Chưa có đề xuất đáp án mới.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : Column(
                              children: state.proposals.map((proposal) {
                                return PollOptionProposalItem(
                                  proposal: proposal,
                                  poll: widget.poll,
                                  actionLoading: state.actionLoading,
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
