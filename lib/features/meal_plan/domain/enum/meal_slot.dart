import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum MealSlot {
  @JsonValue('BREAKFAST')
  breakfast('BREAKFAST'),

  @JsonValue('LUNCH')
  lunch('LUNCH'),

  @JsonValue('DINNER')
  dinner('DINNER'),

  @JsonValue('SNACK')
  snack('SNACK');

  const MealSlot(this.value);

  final String value;
}
