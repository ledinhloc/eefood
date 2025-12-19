import 'package:eefood/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../data/models/recipe_detail_model.dart';
import '../../domain/repositories/recipe_repository.dart';

class RecipeDetailState {
  final bool isLoading;
  final RecipeDetailModel? recipe;
  final String? error;

  const RecipeDetailState({
    this.isLoading = false,
    this.recipe,
    this.error,
  });

  RecipeDetailState copyWith({
    bool? isLoading,
    RecipeDetailModel? recipe,
    String? error,
  }) {
    return RecipeDetailState(
      isLoading: isLoading ?? this.isLoading,
      recipe: recipe ?? this.recipe,
      error: error ?? this.error,
    );
  }
}

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final RecipeRepository repository = getIt<RecipeRepository>();
  RecipeDetailCubit() : super(const RecipeDetailState());
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();

  DateTime? _viewStartTime;
  int? _currentRecipeId;
  bool _hasLoggedView = false;

  Future<void> loadRecipe(int recipeId) async {
    emit(state.copyWith(isLoading: true));

    _startTracking(recipeId);
    try {
      final recipe = await repository.fetchRecipeDetail(recipeId);
      emit(state.copyWith(isLoading: false, recipe: recipe));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _startTracking(int recipeId) {
    _viewStartTime = DateTime.now();
    _currentRecipeId = recipeId;
    _hasLoggedView = false;
    print('Started tracking recipe $recipeId at $_viewStartTime');
  }

  Future<void> stopTracking() async {
    if (_viewStartTime == null || _currentRecipeId == null || _hasLoggedView) {
      return;
    }

    // Check user có đăng nhập không
    final user = await _getCurrentUser();
    if (user == null) {
      print('Guest user - không log view');
      return;
    }

    // Tính thời gian xem
    final viewDuration = DateTime.now().difference(_viewStartTime!).inSeconds;

    // Chỉ log nếu xem ít nhất 2 giây
    if (viewDuration < 2) {
      print(' View duration too short: $viewDuration seconds');
      return;
    }

    try {
      await repository.logPostView(
        postId: _currentRecipeId!,
        viewDuration: viewDuration,
        viewedAt: _viewStartTime!,
      );

      _hasLoggedView = true;
      print(' Logged view: recipe=$_currentRecipeId, duration=$viewDuration seconds');
    } catch (e) {
      print(' Failed to log view: $e');
    }
  }
}
