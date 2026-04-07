import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum MealPlanItemSource {
  @JsonValue('RECIPE')
  recipe('RECIPE'),

  @JsonValue('CUSTOM')
  custom('CUSTOM');

  const MealPlanItemSource(this.value);

  final String value;
}
