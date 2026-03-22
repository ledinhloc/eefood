import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';

enum NutritionStatus { idle, uploading, analyzing, partialSuccess,success, error }

enum NutritionRenderPhase { none, nutritionReady, analysisReady }

class NutritionState {
  final NutritionStatus status;
  final String? statusMessage;
  final NutritionAnalysisModel? result;
  final NutritionRenderPhase renderPhase;
  final String? error;

  const NutritionState({
    this.status = NutritionStatus.idle,
    this.statusMessage,
    this.result,
    this.renderPhase = NutritionRenderPhase.none,
    this.error,
  });

  NutritionState copyWith({
    NutritionStatus? status,
    String? statusMessage,
    NutritionAnalysisModel? result,
    NutritionRenderPhase? renderPhase,
    String? error,
  }) {
    return NutritionState(
      status: status ?? this.status,
      statusMessage: statusMessage,
      result: result ?? this.result,
      renderPhase: renderPhase ?? this.renderPhase,
      error: error,
    );
  }

  bool get isLoading =>
      status == NutritionStatus.uploading ||
      status == NutritionStatus.analyzing;

  bool get hasNutritionData =>
      renderPhase == NutritionRenderPhase.nutritionReady ||
      renderPhase == NutritionRenderPhase.analysisReady;

  bool get hasAnalysisData => renderPhase == NutritionRenderPhase.analysisReady;
}
