// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_gift_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendGiftRequest _$SendGiftRequestFromJson(Map<String, dynamic> json) =>
    SendGiftRequest(
      giftItemId: (json['giftItemId'] as num?)?.toInt(),
      livestreamId: (json['livestreamId'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SendGiftRequestToJson(SendGiftRequest instance) =>
    <String, dynamic>{
      'giftItemId': instance.giftItemId,
      'livestreamId': instance.livestreamId,
      'quantity': instance.quantity,
    };
