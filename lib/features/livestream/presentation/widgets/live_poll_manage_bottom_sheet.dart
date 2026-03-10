import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/live_poll_response.dart';
import '../../domain/enum/poll_status.dart';
import '../provider/live_poll_cubit.dart';
import '../provider/live_poll_state.dart';
import 'create_poll_bottom_sheet.dart';

class LivePollManageBottomSheet extends StatelessWidget {
  const LivePollManageBottomSheet({super.key});

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
                ? const _EmptyPollView()
                : _PollManageContent(
                    poll: poll,
                    state: state,
                  ),
          ),
        );
      },
    );
  }
}

class _EmptyPollView extends StatelessWidget {
  const _EmptyPollView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Chưa có poll',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hãy tạo poll mới để bắt đầu',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCreatePollSheet(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Tạo poll mới'),
          ),
        ),
      ],
    );
  }

  void _showCreatePollSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<LivePollCubit>(),
          child: const CreatePollBottomSheet(),
        );
      },
    );
  }
}

class _PollManageContent extends StatelessWidget {
  final LivePollResponse poll;
  final LivePollState state;

  const _PollManageContent({
    required this.poll,
    required this.state,
  });

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
            'Quản lý poll',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          _buildInfoCard(
            title: 'Câu hỏi',
            value: poll.question,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Trạng thái',
            value: _statusText(poll.status),
            valueColor: _statusColor(poll.status),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Số đáp án',
            value: '${poll.options.length}',
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: state.actionLoading || poll.status == PollStatus.open
                      ? null
                      : () => cubit.openPoll(pollId: poll.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Mở poll'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: state.actionLoading || poll.status == PollStatus.closed
                      ? null
                      : () => cubit.closePoll(pollId: poll.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Đóng poll'),
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
              child: const Text('Xem kết quả'),
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
                      _showCreatePollSheet(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Tạo poll mới'),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'Kết quả',
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
                'Chưa có dữ liệu kết quả. Nhấn "Xem kết quả" để tải.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            ...state.result!.options.map(
              (item) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  ],
                ),
              ),
            ),

          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreatePollSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<LivePollCubit>(),
          child: const CreatePollBottomSheet(),
        );
      },
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
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
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
        return 'Đang mở';
      case PollStatus.closed:
        return 'Đã đóng';
      default:
        return 'Chưa mở';
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