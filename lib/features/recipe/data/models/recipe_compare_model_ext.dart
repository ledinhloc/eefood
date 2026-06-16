// recipe_compare_model_ext.dart
import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';
import 'package:eefood/features/recipe/data/models/recipe_compare_model.dart';

extension RecipeCompareModelPatch on RecipeCompareModel {
  RecipeCompareModel patchFromNutrition(NutritionAnalysisModel n) {
    return RecipeCompareModel(
      id: id,
      title: title, 
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      prepTime: prepTime,
      cookTime: cookTime,
      totalTime: totalTime,
      difficulty: difficulty,
      region: region,
      stepCount: stepCount,
      ingredientCount: ingredientCount,
      calories: n.totalCalories ?? calories,
      protein: n.totalProtein ?? protein,
      fat: n.totalFat ?? fat,
      carb: n.totalCarb ?? carb,
      fiber: n.totalFiber ?? fiber,
      sugar: n.totalSugar ?? sugar,
      sodium: n.totalSodium ?? sodium,
      healthScore: n.healthScore ?? healthScore,
      cal: cal,
    );
  }
}
