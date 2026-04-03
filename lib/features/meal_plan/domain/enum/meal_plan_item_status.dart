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

extension MealPlanItemStatusX on MealPlanItemStatus {
  String get label {
    switch (this) {
      case MealPlanItemStatus.planned:
        return 'Đã lên kế hoạch';
      case MealPlanItemStatus.done:
        return 'Đã ăn';
      case MealPlanItemStatus.skipped:
        return 'Đã bỏ qua';
    }
  }
}
