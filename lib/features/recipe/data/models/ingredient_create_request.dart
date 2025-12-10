import 'package:json_annotation/json_annotation.dart';

part 'ingredient_create_request.g.dart';

@JsonSerializable()
class IngredientCreateRequest {
  final String name;
  final double? quantity;
  final String? unit;

  IngredientCreateRequest({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory IngredientCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$IngredientCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientCreateRequestToJson(this);
}
