import 'package:eefood/features/nutrition/data/models/nutrition_stream_event.dart';

abstract class NutritionRepository {
  Stream<NutritionStreamEvent> analyzeStreamByImageUrl(String imageUrl);
  Stream<NutritionStreamEvent> analyzeStreamByRecipeId(
    int recipeId,
    bool forceRefresh,
  );
}
