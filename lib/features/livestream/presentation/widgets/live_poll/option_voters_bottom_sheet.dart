import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/livestream/data/model/live_poll_option_voter_response.dart';
import 'package:eefood/features/livestream/presentation/provider/live_poll_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_poll_state.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OptionVotersBottomSheet extends StatelessWidget {
  final int optionId;
  final String optionText;

  const OptionVotersBottomSheet({
    required this.optionId,
    required this.optionText,
  });

  Future<void> _openUserProfile(
    BuildContext context,
    PollOptionVoterResponse voter,
  ) async {
    final userId = voter.userId;
    if (userId == null) return;

    try {
      User? userStory = await getIt<GetUserById>().call(userId);
      if (!context.mounted || userStory == null) return;

      await Navigator.pushNamed(
        context,
        AppRoutes.personalUser,
        arguments: {'user': userStory},
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Khong the mo trang ca nhan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: BlocBuilder<LivePollCubit, LivePollState>(
          builder: (context, state) {
            final votersResponse = state.optionVoters;
            final isCurrentOption = votersResponse?.optionId == optionId;
            final voters =
                isCurrentOption ? votersResponse?.voters ?? const [] : const [];

            return Column(
              mainAxisSize: MainAxisSize.min,
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
                Text(
                  optionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Danh sach nguoi vote',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                if (state.optionVotersLoading && !isCurrentOption)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else if (voters.isEmpty)
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
                    child: const Text(
                      'Chua co nguoi vote cho lua chon nay.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: voters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final voter = voters[index];
                        return InkWell(
                          onTap: () => _openUserProfile(context, voter),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[700],
                                  backgroundImage: voter.avatarUrl != null &&
                                          voter.avatarUrl!.isNotEmpty
                                      ? NetworkImage(voter.avatarUrl!)
                                      : null,
                                  child: voter.avatarUrl == null ||
                                          voter.avatarUrl!.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    voter.username ?? 'Nguoi dung',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
