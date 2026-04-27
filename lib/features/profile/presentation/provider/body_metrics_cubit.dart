import 'package:eefood/features/profile/data/models/user_height_request.dart';
import 'package:eefood/features/profile/data/models/user_height_response.dart';
import 'package:eefood/features/profile/data/models/user_weight_request.dart';
import 'package:eefood/features/profile/data/models/user_weight_response.dart';
import 'package:eefood/features/profile/domain/repositories/body_metrics_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'body_metrics_state.dart';

class BodyMetricsCubit extends Cubit<BodyMetricsState> {
  final BodyMetricsRepository repository;

  BodyMetricsCubit({required this.repository})
    : super(const BodyMetricsState());

  List<UserHeightResponse> _sortHeights(List<UserHeightResponse> values) {
    final sorted = [...values];
    sorted.sort((a, b) {
      final aDate = a.recordedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.recordedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  List<UserWeightResponse> _sortWeights(List<UserWeightResponse> values) {
    final sorted = [...values];
    sorted.sort((a, b) {
      final aDate = a.recordedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.recordedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final results = await Future.wait<Object>([
        repository.getMyHeights(),
        repository.getMyWeights(),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          heights: _sortHeights(results[0] as List<UserHeightResponse>),
          weights: _sortWeights(results[1] as List<UserWeightResponse>),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<bool> createHeight({
    required double heightCm,
    DateTime? recordedDate,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final item = await repository.createMyHeight(
        UserHeightRequest(heightCm: heightCm, recordedDate: recordedDate),
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          heights: _sortHeights([item, ...state.heights]),
        ),
      );
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> updateHeight({
    required int id,
    required double heightCm,
    DateTime? recordedDate,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final item = await repository.updateMyHeight(
        id,
        UserHeightRequest(heightCm: heightCm, recordedDate: recordedDate),
      );
      final next = state.heights.map((current) {
        return current.id == id ? item : current;
      }).toList();
      emit(state.copyWith(isSubmitting: false, heights: _sortHeights(next)));
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> deleteHeight(int id) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await repository.deleteMyHeight(id);
      emit(
        state.copyWith(
          isSubmitting: false,
          heights: state.heights.where((item) => item.id != id).toList(),
        ),
      );
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> createWeight({
    required double weightKg,
    DateTime? recordedDate,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final item = await repository.createMyWeight(
        UserWeightRequest(weightKg: weightKg, recordedDate: recordedDate),
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          weights: _sortWeights([item, ...state.weights]),
        ),
      );
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> updateWeight({
    required int id,
    required double weightKg,
    DateTime? recordedDate,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final item = await repository.updateMyWeight(
        id,
        UserWeightRequest(weightKg: weightKg, recordedDate: recordedDate),
      );
      final next = state.weights.map((current) {
        return current.id == id ? item : current;
      }).toList();
      emit(state.copyWith(isSubmitting: false, weights: _sortWeights(next)));
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> deleteWeight(int id) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await repository.deleteMyWeight(id);
      emit(
        state.copyWith(
          isSubmitting: false,
          weights: state.weights.where((item) => item.id != id).toList(),
        ),
      );
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }
}
