import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nutrition_stream_event.g.dart';

enum NutritionEventType { status, nutrition, analysis, error, complete }

@JsonSerializable()
class NutritionStreamEvent {
  final NutritionEventType type;
  final String? message;
  final NutritionAnalysisModel? data;

  NutritionStreamEvent({required this.type, this.message, this.data});

  factory NutritionStreamEvent.fromJson(Map<String, dynamic> json) =>
      _$NutritionStreamEventFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionStreamEventToJson(this);
}
