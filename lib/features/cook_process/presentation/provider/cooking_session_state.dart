import 'package:eefood/features/cook_process/data/models/cooking_session_response.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

enum CookingStatus { initial, loading, ready, saving, completing, done, error }
class CookingSessionState {
  final CookingStatus status;
  final CookingSessionResponse? session;
  final List<RecipeStepModel> steps;
  final int currentStepIndex;
  final bool isCompleted;
  final String? error;

  const CookingSessionState({
    this.status = CookingStatus.initial,
    this.session,
    this.steps = const [],
    this.currentStepIndex = 0,
    this.isCompleted = false,
    this.error,
  });

  bool get isLastStep => currentStepIndex >= steps.length - 1;
  bool get isFirstStep => currentStepIndex == 0;
  RecipeStepModel? get currentStep =>
      steps.isNotEmpty ? steps[currentStepIndex] : null;

  CookingSessionState copyWith({
    CookingStatus? status,
    CookingSessionResponse? session,
    List<RecipeStepModel>? steps,
    int? currentStepIndex,
    bool? isCompleted,
    String? error,
  }) {
    return CookingSessionState(
      status: status ?? this.status,
      session: session ?? this.session,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
}