import 'package:eefood/features/cook_process/data/models/cooking_session_progress_response.dart';
import 'package:eefood/features/cook_process/data/models/cooking_session_response.dart';

abstract class CookingSessionRepository {
  Future<bool> isCompleted(int recipeId);
  Future<CookingSessionResponse?> getOrCreateCookingSession(int recipeId);
  Future<CookingSessionProgressResponse?> saveProgress(
    int sessionId,
    int currentStep,
  );
  Future<CookingSessionProgressResponse?> completeSession(int sessionId);
}
