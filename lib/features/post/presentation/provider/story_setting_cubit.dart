import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/story_setting_model.dart';
import 'package:eefood/features/post/domain/repositories/story_setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StorySettingCubit extends Cubit<StorySettingState> {
  final StorySettingRepository repository = getIt<StorySettingRepository>();

  StorySettingCubit() : super(StorySettingState.initial());

  void _safeEmit(StorySettingState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> loadSetting(int userId) async {
    _safeEmit(
      state.copyWith(isLoading: true, clearError: true, clearSuccess: true),
    );

    try {
      final setting = await repository.getSetting(userId);
      _safeEmit(state.copyWith(settingModel: setting, isLoading: false));
    } catch (e) {
      _safeEmit(
        state.copyWith(
          settingModel: StorySettingModel(
            userId: userId,
            mode: StoryMode.FOLLOWING_ONLY,
          ),
          isLoading: false,
        ),
      );
    }
  }

  void updateMode(StoryMode mode) {
    if (state.settingModel == null) return;

    _safeEmit(
      state.copyWith(
        settingModel: StorySettingModel(
          id: state.settingModel!.id,
          userId: state.settingModel!.userId,
          mode: mode,
          allowedUserIds: mode == StoryMode.CUSTOM_INCLUDE
              ? state.settingModel!.allowedUserIds
              : null,
          blockedUserIds: mode == StoryMode.BLACKLIST
              ? state.settingModel!.blockedUserIds
              : null,
        ),
      ),
    );
  }

  void updateAllowedUsers(List<int> userIds) {
    if (state.settingModel == null) return;

    _safeEmit(
      state.copyWith(
        settingModel: StorySettingModel(
          id: state.settingModel!.id,
          userId: state.settingModel!.userId,
          mode: state.settingModel!.mode,
          allowedUserIds: userIds,
          blockedUserIds: state.settingModel!.blockedUserIds,
        ),
      ),
    );
  }

  void updateBlockedUsers(List<int> userIds) {
    if (state.settingModel == null) return;

    _safeEmit(
      state.copyWith(
        settingModel: StorySettingModel(
          id: state.settingModel!.id,
          userId: state.settingModel!.userId,
          mode: state.settingModel!.mode,
          allowedUserIds: state.settingModel!.allowedUserIds,
          blockedUserIds: userIds,
        ),
      ),
    );
  }

  Future<void> saveSetting() async {
    if (state.settingModel == null) return;

    _safeEmit(
      state.copyWith(isSaving: true, clearError: true, clearSuccess: true),
    );

    try {
      debugPrint('Id của setting ${state.settingModel!.id}');
      final savedSetting = await repository.saveSetting(state.settingModel!);

      _safeEmit(
        state.copyWith(
          settingModel: savedSetting,
          isSaving: false,
          success: 'Lưu cài đặt thành công',
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isSaving: false,
          error: 'Không thể lưu cài đặt. Vui lòng thử lại.',
        ),
      );
    }
  }

  void clearMessages() {
    _safeEmit(state.copyWith(clearError: true, clearSuccess: true));
  }
}

class StorySettingState {
  final StorySettingModel? settingModel;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? success;

  StorySettingState({
    this.settingModel,
    required this.isLoading,
    required this.isSaving,
    this.error,
    this.success,
  });

  factory StorySettingState.initial() =>
      StorySettingState(isLoading: false, isSaving: false);

  StorySettingState copyWith({
    StorySettingModel? settingModel,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? success,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return StorySettingState(
      settingModel: settingModel ?? this.settingModel,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      success: clearSuccess ? null : (success ?? this.success),
    );
  }
}
