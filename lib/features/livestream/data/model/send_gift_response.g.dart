// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_gift_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendGiftResponse _$SendGiftResponseFromJson(Map<String, dynamic> json) =>
    SendGiftResponse(
      giftLogId: (json['giftLogId'] as num?)?.toInt(),
      senderId: (json['senderId'] as num?)?.toInt(),
      senderName: json['senderName'] as String?,
      senderImageUrl: json['senderImageUrl'] as String?,
      receiverId: (json['receiverId'] as num?)?.toInt(),
      livestreamId: (json['livestreamId'] as num?)?.toInt(),
      giftItemId: (json['giftItemId'] as num?)?.toInt(),
      giftName: json['giftName'] as String?,
      animationUrl: json['animationUrl'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      totalDiamondSpent: (json['totalDiamondSpent'] as num?)?.toInt(),
      senderNewBalance: (json['senderNewBalance'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SendGiftResponseToJson(SendGiftResponse instance) =>
    <String, dynamic>{
      'giftLogId': instance.giftLogId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderImageUrl': instance.senderImageUrl,
      'receiverId': instance.receiverId,
      'livestreamId': instance.livestreamId,
      'giftItemId': instance.giftItemId,
      'giftName': instance.giftName,
      'animationUrl': instance.animationUrl,
      'quantity': instance.quantity,
      'totalDiamondSpent': instance.totalDiamondSpent,
      'senderNewBalance': instance.senderNewBalance,
    };
