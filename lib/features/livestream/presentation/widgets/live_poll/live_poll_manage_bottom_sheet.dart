import 'package:eefood/features/livestream/presentation/widgets/live_poll/option_voters_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/live_poll_response.dart';
import '../../../domain/enum/poll_status.dart';
import '../../provider/live_poll_cubit.dart';
import '../../provider/live_poll_option_proposal_cubit.dart';
import '../../provider/live_poll_state.dart';
import 'poll_option_proposal_section.dart';

class LivePollManageBottomSheet extends StatelessWidget {
  final VoidCallback onCreateNewPoll;

  const LivePollManageBottomSheet({super.key, required this.onCreateNewPoll});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LivePollOptionProposalCubit(),
      child: BlocBuilder<LivePollCubit, LivePollState>(
        builder: (context, state) {
          final poll = state.poll;

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: poll == null
                  ? _EmptyPollView(onCreateNewPoll: onCreateNewPoll)
                  : _PollManageContent(
                      poll: poll,
                      state: state,
                      onCreateNewPoll: onCreateNewPoll,
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyPollView extends StatelessWidget {
  final VoidCallback onCreateNewPoll;

  const _EmptyPollView({required this.onCreateNewPoll});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Chua co poll',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hay tao poll moi de bat dau',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onCreateNewPoll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Tao poll moi'),
          ),
        ),
      ],
    );
  }
}

class _PollManageContent extends StatelessWidget {
  final LivePollResponse poll;
  final LivePollState state;
  final VoidCallback onCreateNewPoll;

  const _PollManageContent({
    required this.poll,
    required this.state,
    required this.onCreateNewPoll,
  });

  Future<void> _showOptionVoters(
    BuildContext context, {
    required int optionId,
    required String optionText,
  }) async {
    final cubit = context.read<LivePollCubit>();
    cubit.clearOptionVoters();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: OptionVotersBottomSheet(
          optionId: optionId,
          optionText: optionText,
        ),
      ),
    );

    await cubit.loadOptionVoters(optionId: optionId, pollId: poll.id);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LivePollCubit>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quan ly poll',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(title: 'Câu hỏi', value: poll.question),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Trạng thái',
            value: _statusText(poll.status),
            valueColor: _statusColor(poll.status),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(title: 'Số đáp án', value: '${poll.options.length}'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      state.actionLoading || poll.status == PollStatus.open
                      ? null
                      : () => cubit.openPoll(pollId: poll.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Mo poll'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      state.actionLoading || poll.status == PollStatus.closed
                      ? null
                      : () => cubit.closePoll(pollId: poll.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Dong poll'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.loading
                  ? null
                  : () => cubit.loadPollResult(pollId: poll.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Xem ket qua'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.actionLoading
                  ? null
                  : () {
                      cubit.prepareForNewPoll();
                      Navigator.pop(context);
                      onCreateNewPoll();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Tao poll moi'),
            ),
          ),
          const Text(
            'Ket qua',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (state.result == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Chua co du lieu ket qua. Nhan "Xem ket qua" de tai.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            ...state.result!.options.map(
              (item) => GestureDetector(
                onTap: () => _showOptionVoters(
                  context,
                  optionId: item.id,
                  optionText: item.text,
                ),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        '${item.count}',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          PollOptionProposalSection(poll: poll),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(PollStatus status) {
    switch (status) {
      case PollStatus.open:
        return 'Dang mo';
      case PollStatus.closed:
        return 'Da dong';
      default:
        return 'Chua mo';
    }
  }

  Color _statusColor(PollStatus status) {
    switch (status) {
      case PollStatus.open:
        return Colors.greenAccent;
      case PollStatus.closed:
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }
}
