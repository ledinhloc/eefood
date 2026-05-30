// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_gift_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveGiftItemResponse _$LiveGiftItemResponseFromJson(
        Map<String, dynamic> json) =>
    LiveGiftItemResponse(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      animationUrl: json['animationUrl'] as String?,
      diamondCost: (json['diamondCost'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LiveGiftItemResponseToJson(
        LiveGiftItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'animationUrl': instance.animationUrl,
      'diamondCost': instance.diamondCost,
    };
