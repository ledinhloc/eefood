import 'package:eefood/features/livestream/domain/enum/poll_result_visibility.dart';
import 'package:eefood/features/livestream/domain/enum/poll_voter_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/live_poll_response.dart';
import '../../../domain/enum/poll_status.dart';
import '../../provider/live_poll_cubit.dart';
import '../../provider/live_poll_state.dart';
import 'option_voters_bottom_sheet.dart';

class LivePollViewerBottomSheet extends StatelessWidget {
  const LivePollViewerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivePollCubit, LivePollState>(
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
                ? const _NoPollView()
                : _PollViewerContent(poll: poll, state: state),
          ),
        );
      },
    );
  }
}

class _NoPollView extends StatelessWidget {
  const _NoPollView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8),
        Text(
          'Hiện chưa có poll',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Khi streamer tạo poll, bạn sẽ thấy tại đây',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PollViewerContent extends StatelessWidget {
  final LivePollResponse poll;
  final LivePollState state;

  const _PollViewerContent({required this.poll, required this.state});

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
    final canShowResult = cubit.shouldShowResult;
    final canShowVoters =
        poll.setting.voterVisibility == PollVoterVisibility.public;

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
            'Bình chọn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              poll.question,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _statusText(poll.status),
              style: TextStyle(
                color: _statusColor(poll.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (poll.status == PollStatus.open) ...[
            const Text(
              'Chọn đáp án',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...poll.options.map((option) {
              final isSelected = state.selectedOptionIds.contains(option.id);

              return GestureDetector(
                onTap: () => cubit.toggleOption(optionId: option.id),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.orange.withValues(alpha: 0.22)
                        : const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.orange),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.actionLoading
                    ? null
                    : () => cubit.vote(pollId: poll.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: state.actionLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(state.hasVoted ? 'Bình chọn lại' : 'Gửi bình chọn'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (canShowResult) ...[
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
                child: Text(
                  state.result == null ? 'Xem ket qua' : 'Lam moi ket qua',
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.loading && state.result == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.result != null) ...[
              const Text(
                'Kết quả',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tong so phieu: ${state.result!.totalVotes}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              ...state.result!.options.map(
                (item) => GestureDetector(
                  onTap: canShowVoters
                      ? () => _showOptionVoters(
                          context,
                          optionId: item.id,
                          optionText: item.text,
                        )
                      : null,
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
                        if (canShowVoters) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                _resultVisibilityMessage(),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }

  String _statusText(PollStatus status) {
    switch (status) {
      case PollStatus.open:
        return 'Đang mở bình chọn';
      case PollStatus.closed:
        return 'Poll đã đóng';
      default:
        return 'Poll chưa mở';
    }
  }

  Color _statusColor(PollStatus status) {
    switch (status) {
      case PollStatus.open:
        return Colors.greenAccent;
      case PollStatus.closed:
        return Colors.orangeAccent;
      default:
        return Colors.white70;
    }
  }

  String _resultVisibilityMessage() {
    switch (poll.setting.resultVisibility) {
      case PollResultVisibility.always:
        return 'Ket qua se hien tai day.';
      case PollResultVisibility.afterVote:
        return state.hasVoted
            ? 'Ket qua dang duoc cap nhat.'
            : 'Ban can binh chon truoc khi xem ket qua.';
      case PollResultVisibility.afterClose:
        return poll.status == PollStatus.closed
            ? 'Ket qua dang duoc cap nhat.'
            : 'Ket qua se hien khi poll dong.';
    }
  }
}
