import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';
import 'package:eefood/features/nutrition/data/models/nutrition_stream_event.dart';
import 'package:eefood/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:http_parser/http_parser.dart';

class NutritionRepositoryImpl extends NutritionRepository {
  final Dio dio;
  NutritionRepositoryImpl({required this.dio});

  @override
  Stream<NutritionStreamEvent> analyzeStreamByImage(
    File imageFile
  ) async* {

    final String fileName = imageFile.path.split('/').last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    final response = await dio.post<ResponseBody>(
      "/v1/nutrition/image/stream",
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        responseType: ResponseType.stream,
        headers: {"Accept": "text/event-stream", "Cache-Control": "no-cache"},
      ),
    );

    yield* _parseEventAndData(response);
  }

  @override
  Stream<NutritionStreamEvent> analyzeStreamByRecipeId(
    int recipeId,
    bool forceRefresh,
  ) async* {
    final response = await dio.post<ResponseBody>(
      "/v1/nutrition/recipe/$recipeId/stream",
      queryParameters: {'forceRefresh': forceRefresh},
      options: Options(
        responseType: ResponseType.stream,
        headers: {"Accept": "text/event-stream", "Cache-Control": "no-cache"},
      ),
    );

    yield* _parseEventAndData(response);
  }

  Stream<NutritionStreamEvent> _parseEventAndData(var response) async* {
    final stream = response.data!.stream.cast<List<int>>().transform(
      utf8.decoder,
    );

    String buffer = '';

    await for (final chunk in stream) {
      buffer += chunk;

      while (buffer.contains('\n\n')) {
        final eventBlock = buffer.substring(0, buffer.indexOf('\n\n'));
        buffer = buffer.substring(buffer.indexOf('\n\n') + 2);

        String? eventName;
        String? dataLine;

        for (final line in eventBlock.split('\n')) {
          if (line.startsWith('event:')) {
            eventName = line.replaceFirst('event:', '').trim();
          } else if (line.startsWith('data:')) {
            dataLine = line.replaceFirst('data:', '').trim();
          }
        }

        if (dataLine != null && dataLine.isNotEmpty) {
          final json = jsonDecode(dataLine);
          yield _mapToEvent(eventName, json);
        }
      }
    }
  }

  NutritionStreamEvent _mapToEvent(String? event, dynamic json) {
    switch (event) {
      case "status":
        return NutritionStreamEvent(
          type: NutritionEventType.status,
          message: json["message"] as String?,
          data: null,
        );

      case "nutrition":
        final rawData = json["data"];
        return NutritionStreamEvent(
          type: NutritionEventType.nutrition,
          message: null,
          data: rawData is Map<String, dynamic>
              ? NutritionAnalysisModel.fromJson(rawData)
              : null,
        );

      case "analysis":
        final rawData = json["data"];
        final parsed = rawData is Map<String, dynamic>
            ? NutritionAnalysisModel.fromJson(rawData)
            : null;
        return NutritionStreamEvent(
          type: NutritionEventType.analysis,
          message: parsed?.summary,
          data: parsed,
        );

      case "error":
        return NutritionStreamEvent(
          type: NutritionEventType.error,
          message: json["message"] as String?,
          data: null,
        );

      case "complete":
        return NutritionStreamEvent(
          type: NutritionEventType.complete,
          message: json["message"] as String?,
          data: null,
        );

      default:
        return NutritionStreamEvent(
          type: NutritionEventType.status,
          message: json["message"] as String?,
          data: null,
        );
    }
  }
}
