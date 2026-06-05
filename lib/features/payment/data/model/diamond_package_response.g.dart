// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diamond_package_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiamondPackageResponse _$DiamondPackageResponseFromJson(
        Map<String, dynamic> json) =>
    DiamondPackageResponse(
      id: (json['id'] as num?)?.toInt(),
      diamondAmount: (json['diamondAmount'] as num?)?.toInt(),
      bonusDiamond: (json['bonusDiamond'] as num?)?.toInt(),
      price: json['price'] as num?,
      currency: json['currency'] as String?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$DiamondPackageResponseToJson(
        DiamondPackageResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'diamondAmount': instance.diamondAmount,
      'bonusDiamond': instance.bonusDiamond,
      'price': instance.price,
      'currency': instance.currency,
      'isActive': instance.isActive,
    };
