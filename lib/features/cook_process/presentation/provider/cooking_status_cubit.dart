import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eefood/features/cook_process/data/models/cooking_session_response.dart';
import 'package:eefood/features/cook_process/domain/repositories/cooking_session_repository.dart';

class CookingStatusState extends Equatable {
  final bool isLoading;
  final bool isCompleted;
  final CookingSessionStatus? sessionStatus;

  const CookingStatusState({
    this.isLoading = false,
    this.isCompleted = false,
    this.sessionStatus,
  });

  /// Chưa có session nào
  bool get isNew => sessionStatus == null;

  /// Đang làm dở
  bool get isInProgress =>
      !isCompleted &&
      sessionStatus != null &&
      sessionStatus != CookingSessionStatus.COMPLETED;

  String get buttonLabel {
    if (isCompleted) return 'Làm lại món ăn';
    if (isInProgress) return 'Tiếp tục thực hiện';
    return 'Bắt đầu nấu ăn';
  }

  CookingStatusState copyWith({
    bool? isLoading,
    bool? isCompleted,
    CookingSessionStatus? sessionStatus,
    bool clearSessionStatus = false,
  }) {
    return CookingStatusState(
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      sessionStatus: clearSessionStatus
          ? null
          : sessionStatus ?? this.sessionStatus,
    );
  }

  @override
  List<Object?> get props => [isLoading, isCompleted, sessionStatus];
}


class CookingStatusCubit extends Cubit<CookingStatusState> {
  final CookingSessionRepository repository;

  CookingStatusCubit({required this.repository})
    : super(const CookingStatusState());

  void _safeEmit(CookingStatusState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> load(int recipeId) async {
    _safeEmit(state.copyWith(isLoading: true));
    try {
      final isCompleted = await repository.isCompleted(recipeId);
      CookingSessionResponse? session;
      if (!isCompleted) {
        session = await repository.getOrCreateCookingSession(
          recipeId,
        );
      }

      _safeEmit(
        state.copyWith(
          isLoading: false,
          isCompleted: isCompleted,
          sessionStatus: session?.status,
          clearSessionStatus: session == null,
        ),
      );
    } catch (_) {
      _safeEmit(state.copyWith(isLoading: false));
    }
  }
}
