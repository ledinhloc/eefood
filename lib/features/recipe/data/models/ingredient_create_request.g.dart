// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IngredientCreateRequest _$IngredientCreateRequestFromJson(
  Map<String, dynamic> json,
) => IngredientCreateRequest(
  name: json['name'] as String,
  quantity: (json['quantity'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$IngredientCreateRequestToJson(
  IngredientCreateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'quantity': instance.quantity,
  'unit': instance.unit,
};
