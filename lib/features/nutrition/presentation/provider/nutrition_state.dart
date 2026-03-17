import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';

enum NutritionStatus { idle, uploading, analyzing, success, error }

class NutritionState {
  final NutritionStatus status;
  final String? statusMessage;
  final NutritionAnalysisModel? result;
  final String? error;

  const NutritionState({
    this.status = NutritionStatus.idle,
    this.statusMessage,
    this.result,
    this.error,
  });

  NutritionState copyWith({
    NutritionStatus? status,
    String? statusMessage,
    NutritionAnalysisModel? result,
    String? error,
  }) {
    return NutritionState(
      status: status ?? this.status,
      statusMessage: statusMessage,
      result: result ?? this.result,
      error: error,
    );
  }

  bool get isLoading =>
      status == NutritionStatus.uploading ||
      status == NutritionStatus.analyzing;

  @override
  List<Object?> get props => [status, statusMessage, result, error];
}