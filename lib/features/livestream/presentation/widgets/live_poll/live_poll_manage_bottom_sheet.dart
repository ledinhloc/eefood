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
import 'live_poll_settings_card.dart';
import 'option_voters_bottom_sheet.dart';
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2E1810), Color(0xFF171314)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
        _buildHandle(),
        const SizedBox(height: 24),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFFF8A3D).withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Color(0xFFFFB067),
            size: 34,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Chưa có poll',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tạo một poll mới để hỏi khán giả hôm nay nên ăn gì.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onCreateNewPoll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A3D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Tạo poll mới',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _PollManageContent extends StatefulWidget {
  final LivePollResponse poll;
  final LivePollState state;
  final VoidCallback onCreateNewPoll;

  const _PollManageContent({
    required this.poll,
    required this.state,
    required this.onCreateNewPoll,
  });

  @override
  State<_PollManageContent> createState() => _PollManageContentState();
}

class _PollManageContentState extends State<_PollManageContent> {
  bool _isSettingsExpanded = false;

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

    await cubit.loadOptionVoters(optionId: optionId, pollId: widget.poll.id);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LivePollCubit>();
    final poll = widget.poll;
    final state = widget.state;
    final setting = poll.setting;
    final canOpen = poll.status == PollStatus.draft;
    final canClose = poll.status == PollStatus.open;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          const SizedBox(height: 18),
          _HeroPollCard(poll: poll),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.track_changes,
                  label: 'Trạng thái',
                  value: _statusText(poll.status),
                  accentColor: _statusColor(poll.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.format_list_bulleted,
                  label: 'Đáp án',
                  value: '${poll.options.length}',
                  accentColor: const Color(0xFFFFB067),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LivePollSettingsCard(
            isExpanded: _isSettingsExpanded,
            summary: _settingsSummary(setting),
            onTap: () {
              setState(() {
                _isSettingsExpanded = !_isSettingsExpanded;
              });
            },
            children: [
              LivePollSettingRow(
                icon: Icons.rule,
                title: 'Kiểu bình chọn',
                value: setting.multipleChoice
                    ? 'Nhiều lựa chọn, tối đa ${setting.maxChoices} đáp án'
                    : 'Chỉ chọn 1 đáp án',
              ),
              LivePollSettingRow(
                icon: Icons.swap_horiz,
                title: 'Đổi bình chọn',
                value: setting.allowChangeVote
                    ? 'Được phép đổi lựa chọn'
                    : 'Không được đổi lựa chọn',
              ),
              LivePollSettingRow(
                icon: Icons.pie_chart_outline,
                title: 'Hiển thị kết quả',
                value: _resultVisibilityText(setting.resultVisibility),
              ),
              LivePollSettingRow(
                icon: Icons.people_outline,
                title: 'Hiển thị người bình chọn',
                value: _voterVisibilityText(setting.voterVisibility),
              ),
              LivePollSettingRow(
                icon: Icons.add_circle_outline,
                title: 'Thêm đáp án',
                value: _optionAddModeText(setting.optionAddMode),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (canOpen || canClose)
            Row(
              children: [
                if (canOpen)
                  Expanded(
                    child: _ActionButton(
                      label: 'Mở poll',
                      icon: Icons.play_arrow_rounded,
                      color: const Color(0xFF3BA55D),
                      onPressed: state.actionLoading
                          ? null
                          : () => cubit.openPoll(pollId: poll.id),
                    ),
                  ),
                if (canOpen && canClose) const SizedBox(width: 12),
                if (canClose)
                  Expanded(
                    child: _ActionButton(
                      label: 'Đóng poll',
                      icon: Icons.stop_rounded,
                      color: const Color(0xFFE35D4B),
                      onPressed: state.actionLoading
                          ? null
                          : () => cubit.closePoll(pollId: poll.id),
                    ),
                  ),
              ],
            ),
          if (canOpen || canClose) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  label: 'Xem kết quả',
                  icon: Icons.bar_chart_rounded,
                  onPressed: state.loading
                      ? null
                      : () => cubit.loadPollResult(pollId: poll.id),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Tạo poll mới',
                  icon: Icons.add_circle_outline,
                  color: const Color(0xFFFF8A3D),
                  onPressed: state.actionLoading
                      ? null
                      : () {
                          cubit.prepareForNewPoll();
                          Navigator.pop(context);
                          widget.onCreateNewPoll();
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Kết quả',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (state.result == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF221C1D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: const Text(
                'Chưa có dữ liệu kết quả. Nhấn "Xem kết quả" để tải.',
                style: TextStyle(color: Colors.white70, height: 1.4),
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
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF221C1D),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFF8A3D,
                          ).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${item.count} lượt',
                          style: const TextStyle(
                            color: Color(0xFFFFB067),
                            fontWeight: FontWeight.w700,
                          ),
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
        return const Color(0xFF68D391);
      case PollStatus.closed:
        return const Color(0xFFFF8A80);
      case PollStatus.draft:
        return const Color(0xFFFFB067);
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

  String _settingsSummary(setting) {
    final choiceText = setting.multipleChoice
        ? 'Nhiều lựa chọn'
        : 'Một lựa chọn';
    final resultText = _resultVisibilityText(setting.resultVisibility);
    return '$choiceText • $resultText';
  }
}

Widget _buildHandle() {
  return Center(
    child: Container(
      width: 46,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(999),
      ),
    ),
  );
}

class _HeroPollCard extends StatelessWidget {
  final LivePollResponse poll;

  const _HeroPollCard({required this.poll});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (poll.status) {
      PollStatus.open => const Color(0xFF68D391),
      PollStatus.closed => const Color(0xFFFF8A80),
      PollStatus.draft => const Color(0xFFFFB067),
    };

    final statusText = switch (poll.status) {
      PollStatus.open => 'Đang mở',
      PollStatus.closed => 'Đã đóng',
      PollStatus.draft => 'Chưa mở',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF513127), Color(0xFF2A2020)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A3D).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_dining, color: Color(0xFFFFB067)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quản lý poll',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            poll.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF221C1D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white12),
        backgroundColor: Colors.white.withValues(alpha: 0.03),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
