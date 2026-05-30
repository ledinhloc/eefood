import 'package:json_annotation/json_annotation.dart';

part 'send_gift_response.g.dart';

@JsonSerializable()
class SendGiftResponse {
  final int? giftLogId;
  final int? senderId;
  final String? senderName;
  final String? senderImageUrl;
  final int? receiverId;
  final int? livestreamId;
  final int? giftItemId;
  final String? giftName;
  final String? animationUrl;
  final int? quantity;
  final int? totalDiamondSpent;
  final int? senderNewBalance;

  SendGiftResponse({
    this.giftLogId,
    this.senderId,
    this.senderName,
    this.senderImageUrl,
    this.receiverId,
    this.livestreamId,
    this.giftItemId,
    this.giftName,
    this.animationUrl,
    this.quantity,
    this.totalDiamondSpent,
    this.senderNewBalance,
  });

  factory SendGiftResponse.fromJson(Map<String, dynamic> json) =>
      _$SendGiftResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SendGiftResponseToJson(this);
}
