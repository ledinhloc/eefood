import 'dart:io';

import 'package:eefood/features/nutrition/data/models/nutrition_stream_event.dart';
import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';

abstract class NutritionRepository {
  Stream<NutritionStreamEvent> analyzeStreamByImage(File imageUrl);
  Stream<NutritionStreamEvent> analyzeStreamByRecipeId(
    int recipeId,
    bool forceRefresh,
  );
  Future<NutritionAnalysisModel> getNutritionByRecipeId(
    int recipeId, {
    bool forceRefresh = false,
  });
}
