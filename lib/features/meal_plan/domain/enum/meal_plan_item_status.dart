import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum MealPlanItemStatus {
  @JsonValue('PLANNED')
  planned('PLANNED'),

  @JsonValue('DONE')
  done('DONE'),

  @JsonValue('SKIPPED')
  skipped('SKIPPED');

  const MealPlanItemStatus(this.value);

  final String value;
}
