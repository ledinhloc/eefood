import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/features/cook_process/data/models/cooking_session_response.dart';
import 'package:eefood/features/cook_process/domain/repositories/cooking_session_repository.dart';
import 'package:eefood/features/cook_process/presentation/provider/cooking_session_state.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookingSessionCubit extends Cubit<CookingSessionState> {
  final CookingSessionRepository repository;
  final SharedPreferences prefs;

  CookingSessionCubit({required this.repository, required this.prefs})
    : super(const CookingSessionState());

  void _safeEmit(CookingSessionState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> initSession(int recipeId, List<RecipeStepModel> steps) async {
    _safeEmit(state.copyWith(status: CookingStatus.loading));
    try {
      final session = await repository.getOrCreateCookingSession(recipeId);
      final startIndex = _resolveStartIndex(session, steps);
      _safeEmit(
        state.copyWith(
          status: CookingStatus.ready,
          session: session,
          steps: steps,
          currentStepIndex: startIndex,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(status: CookingStatus.error, error: e.toString()),
      );
    }
  }

  int _resolveStartIndex(
    CookingSessionResponse? session,
    List<RecipeStepModel> steps,
  ) {
    if (session?.currentStep == null || steps.isEmpty) return 0;
    final idx = session!.currentStep! - 1;
    return idx.clamp(0, steps.length - 1);
  }

  void nextStep() {
    if (!state.isLastStep) {
      _safeEmit(state.copyWith(currentStepIndex: state.currentStepIndex + 1));
    }
  }

  void previousStep() {
    if (!state.isFirstStep) {
      _safeEmit(state.copyWith(currentStepIndex: state.currentStepIndex - 1));
    }
  }

  Future<void> saveProgress() async {
    final sessionId = state.session?.sessionId;
    if (sessionId == null) return;
    _safeEmit(state.copyWith(status: CookingStatus.saving));
    try {
      await repository.saveProgress(sessionId, state.currentStepIndex + 1);
      _safeEmit(state.copyWith(status: CookingStatus.ready));
    } catch (_) {
      _safeEmit(state.copyWith(status: CookingStatus.ready));
    }
  }

  Future<void> completeSession() async {
    final sessionId = state.session?.sessionId;
    if (sessionId == null) return;
    _safeEmit(state.copyWith(status: CookingStatus.completing));
    try {
      await repository.completeSession(sessionId);
      await prefs.setBool(AppKeys.cooking, false);
      _safeEmit(state.copyWith(status: CookingStatus.done, isCompleted: true));
    } catch (e) {
      _safeEmit(
        state.copyWith(status: CookingStatus.error, error: e.toString()),
      );
    }
  }
}
