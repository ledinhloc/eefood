import 'package:eefood/features/profile/data/models/user_height_response.dart';
import 'package:eefood/features/profile/data/models/user_weight_response.dart';

class BodyMetricsState {
  final bool isLoading;
  final bool isSubmitting;
  final List<UserHeightResponse> heights;
  final List<UserWeightResponse> weights;
  final String? error;

  const BodyMetricsState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.heights = const [],
    this.weights = const [],
    this.error,
  });

  UserHeightResponse? get latestHeight {
    if (heights.isEmpty) return null;
    return heights.first;
  }

  UserWeightResponse? get latestWeight {
    if (weights.isEmpty) return null;
    return weights.first;
  }

  double? get bmi {
    final height = latestHeight?.heightCm;
    final weight = latestWeight?.weightKg;
    if (height == null || weight == null || height <= 0 || weight <= 0) {
      return null;
    }
    final heightMeter = height / 100;
    return weight / (heightMeter * heightMeter);
  }

  BodyMetricsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<UserHeightResponse>? heights,
    List<UserWeightResponse>? weights,
    String? error,
    bool clearError = false,
  }) {
    return BodyMetricsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      heights: heights ?? this.heights,
      weights: weights ?? this.weights,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
