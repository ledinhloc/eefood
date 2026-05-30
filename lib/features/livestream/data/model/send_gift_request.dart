import 'package:json_annotation/json_annotation.dart';

part 'send_gift_request.g.dart';

@JsonSerializable()
class SendGiftRequest {
  final int? giftItemId;
  final int? livestreamId;
  final int? quantity;

  SendGiftRequest({
    this.giftItemId,
    this.livestreamId,
    this.quantity,
  });

  factory SendGiftRequest.fromJson(Map<String, dynamic> json) => _$SendGiftRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendGiftRequestToJson(this);
}
