import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/features/livestream/data/model/block_user_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_block_repository.dart';
import '../../../../core/di/injection.dart';
import 'block_user_state.dart';

class BlockUserCubit extends Cubit<BlockUserState> {
  final LiveBlockRepository repo = getIt<LiveBlockRepository>();

  BlockUserCubit() : super(const BlockUserState());

  Future<void> loadBlockedUsers() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await repo.getBlockedUsers();
      emit(state.copyWith(loading: false, users: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> blockUser(int userId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repo.blockUser(userId);
      await loadBlockedUsers();
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> unblockUser(int userId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repo.unblockUser(userId);
      await loadBlockedUsers();
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}