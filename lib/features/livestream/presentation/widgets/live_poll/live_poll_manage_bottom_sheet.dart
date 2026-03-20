import 'package:eefood/features/livestream/presentation/widgets/live_poll/option_voters_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/live_poll_response.dart';
import '../../../domain/enum/poll_option_add_mode.dart';
import '../../../domain/enum/poll_result_visibility.dart';
import '../../../domain/enum/poll_status.dart';
import '../../../domain/enum/poll_voter_visibility.dart';
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
              onCreateNewPoll();
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
    final setting = poll.setting;
    final canOpen = poll.status == PollStatus.draft;
    final canClose = poll.status == PollStatus.open;

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
          const Text(
            'Cài đặt hiện tại',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoCard(
            title: 'Kiểu bình chọn',
            value: setting.multipleChoice
                ? 'Nhiều lựa chọn, tối đa ${setting.maxChoices} đáp án'
                : 'Chỉ chọn 1 đáp án',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Đổi bình chọn',
            value: setting.allowChangeVote ? 'Được phép đổi' : 'Không được đổi',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Hiển thị kết quả',
            value: _resultVisibilityText(setting.resultVisibility),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Hiển thị người bình chọn',
            value: _voterVisibilityText(setting.voterVisibility),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Thêm đáp án',
            value: _optionAddModeText(setting.optionAddMode),
          ),
          const SizedBox(height: 20),
          if (canOpen || canClose)
            Row(
              children: [
                if (canOpen)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.actionLoading
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
                if (canClose)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.actionLoading
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
          if (canOpen || canClose) const SizedBox(height: 12),
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
                      onCreateNewPoll();
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
        return 'Đang mở';
      case PollStatus.closed:
        return 'Đã đóng';
      case PollStatus.draft:
        return 'Chưa mở';
    }
  }

  Color _statusColor(PollStatus status) {
    switch (status) {
      case PollStatus.open:
        return Colors.greenAccent;
      case PollStatus.closed:
        return Colors.redAccent;
      case PollStatus.draft:
        return Colors.orangeAccent;
    }
  }

  String _resultVisibilityText(PollResultVisibility visibility) {
    switch (visibility) {
      case PollResultVisibility.always:
        return 'Luôn hiển thị';
      case PollResultVisibility.afterVote:
        return 'Hiển thị sau khi bình chọn';
      case PollResultVisibility.afterClose:
        return 'Hiển thị sau khi đóng poll';
    }
  }

  String _voterVisibilityText(PollVoterVisibility visibility) {
    switch (visibility) {
      case PollVoterVisibility.anonymous:
        return 'Ẩn danh';
      case PollVoterVisibility.public:
        return 'Công khai';
    }
  }

  String _optionAddModeText(PollOptionAddMode mode) {
    switch (mode) {
      case PollOptionAddMode.hostOnly:
        return 'Chỉ host được thêm đáp án';
      case PollOptionAddMode.viewerWithApproval:
        return 'Viewer đề xuất, host duyệt';
      case PollOptionAddMode.viewerFree:
        return 'Viewer được thêm tự do';
    }
  }
}
