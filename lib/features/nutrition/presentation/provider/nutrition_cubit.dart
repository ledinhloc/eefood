import 'dart:io';

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/features/nutrition/data/models/nutrition_stream_event.dart';
import 'package:eefood/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:eefood/features/nutrition/presentation/provider/nutrition_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NutritionCubit extends Cubit<NutritionState> {
  final NutritionRepository _repository;
  final FileUploader _fileUploader = getIt<FileUploader>();

  NutritionCubit({required NutritionRepository repository})
    : _repository = repository,
      super(const NutritionState());

  Future<void> analyzeImage(File imageFile) async {
    emit(
      state.copyWith(
        status: NutritionStatus.uploading,
        statusMessage: 'Đang tải ảnh lên...',
        error: null,
        result: null,
        renderPhase: NutritionRenderPhase.none,
      ),
    );

    try {

      emit(
        state.copyWith(
          status: NutritionStatus.analyzing,
          statusMessage: 'Đang phân tích dinh dưỡng...',
        ),
      );

      await for (final event in _repository.analyzeStreamByImage(imageFile)) {
        _handleStreamEvent(event);
        if (state.status == NutritionStatus.error) break;
      }
    } catch (e) {
      emit(state.copyWith(status: NutritionStatus.error, error: e.toString()));
    }
  }

  void _handleStreamEvent(NutritionStreamEvent event) {
    switch (event.type) {
      case NutritionEventType.status:
        // Chỉ cập nhật message, giữ nguyên status
        emit(
          state.copyWith(statusMessage: event.message ?? state.statusMessage),
        );

      case NutritionEventType.nutrition:
        if (event.data != null) {
          emit(
            state.copyWith(
              status: NutritionStatus.partialSuccess,
              result: event.data,
              renderPhase: NutritionRenderPhase.nutritionReady,
              statusMessage: 'AI đang phân tích chi tiết...',
            ),
          );
        } else {
          emit(state.copyWith(statusMessage: 'AI đang phân tích chi tiết...'));
        }

      case NutritionEventType.analysis:
        // Full data — có cả AI summary, emit success
        if (event.data != null) {
          emit(
            state.copyWith(
              status: NutritionStatus.success,
              result: event.data,
              renderPhase: NutritionRenderPhase.analysisReady,
              statusMessage: null,
            ),
          );
        }

      case NutritionEventType.error:
        emit(
          state.copyWith(
            status: NutritionStatus.error,
            error: event.message ?? 'Có lỗi xảy ra khi phân tích',
          ),
        );

      case NutritionEventType.complete:
        // Đã xử lý qua analysis event, không làm gì thêm
        break;
    }
  }

  void reset() => emit(const NutritionState());
}
