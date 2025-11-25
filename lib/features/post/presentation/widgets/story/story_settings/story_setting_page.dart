import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/post/data/models/story_setting_model.dart';
import 'package:eefood/features/post/presentation/provider/follow_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_setting_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_settings/story_setting_option_title.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_settings/story_setting_save_button.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_settings/story_user_selector_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StorySettingPage extends StatefulWidget {
  final int userId;

  const StorySettingPage({super.key, required this.userId});

  @override
  State<StorySettingPage> createState() => _StorySettingPageState();
}

class _StorySettingPageState extends State<StorySettingPage> {
  late StorySettingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<StorySettingCubit>();
    _cubit.loadSetting(widget.userId);
  }

  Future<void> _selectUsers(StoryMode mode) async {
    final currentSetting = _cubit.state.settingModel;
    if (currentSetting == null) return;

    final selectedIds = mode == StoryMode.CUSTOM_INCLUDE
        ? currentSetting.allowedUserIds ?? []
        : currentSetting.blockedUserIds ?? [];

    final result = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<FollowCubit>(),
          child: StoryUserSelectorPage(
            userId: widget.userId,
            mode: mode,
            selectedUserIds: selectedIds,
          ),
        ),
      ),
    );

    if (result != null) {
      if (mode == StoryMode.CUSTOM_INCLUDE) {
        _cubit.updateAllowedUsers(result);
      } else {
        _cubit.updateBlockedUsers(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Cài đặt bảng tin',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<StorySettingCubit, StorySettingState>(
        listener: (context, state) {
          if (state.error != null) {
            showCustomSnackBar(context, state.error!, isError: true);
            _cubit.clearMessages();
          }
          if (state.success != null) {
            showCustomSnackBar(context, state.success!);
            _cubit.clearMessages();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) Navigator.pop(context);
            });
          }
        },
        builder: (context, state) {
          print(
            'Current state - isLoading: ${state.isLoading}, isSaving: ${state.isSaving}',
          );
          print('Setting model: ${state.settingModel?.mode}');
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.settingModel == null) {
            return const Center(
              child: Text(
                'Không thể tải cài đặt',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      const Text(
                        'Những người có thể xem tin của bạn',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tin của bạn sẽ được hiển thị trong 24 giờ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Các tùy chọn
                      ...StoryMode.values.map((mode) {
                        final isSelected = state.settingModel!.mode == mode;
                        final needsUserSelection =
                            mode == StoryMode.CUSTOM_INCLUDE ||
                            mode == StoryMode.BLACKLIST;

                        int? selectedCount;
                        if (mode == StoryMode.CUSTOM_INCLUDE) {
                          selectedCount =
                              state.settingModel!.allowedUserIds?.length ?? 0;
                        } else if (mode == StoryMode.BLACKLIST) {
                          selectedCount =
                              state.settingModel!.blockedUserIds?.length ?? 0;
                        }

                        return StorySettingOptionTile(
                          mode: mode,
                          isSelected: isSelected,
                          selectedCount: selectedCount,
                          needsUserSelection: needsUserSelection,
                          onTap: () {
                            _cubit.updateMode(mode);
                            if (needsUserSelection && isSelected) {
                              _selectUsers(mode);
                            }
                          },
                          onSelectUsers: needsUserSelection && isSelected
                              ? () => _selectUsers(mode)
                              : null,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              // Nút Save
              StorySettingSaveButton(
                isSaving: state.isSaving,
                onSave: () => _cubit.saveSetting(),
              ),
            ],
          );
        },
      ),
    );
  }
}
