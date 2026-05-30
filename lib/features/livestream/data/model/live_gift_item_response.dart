import 'package:json_annotation/json_annotation.dart';

part 'live_gift_item_response.g.dart';

@JsonSerializable()
class LiveGiftItemResponse {
  final int? id;
  final String? name;
  final String? imageUrl;
  final String? animationUrl;
  final int? diamondCost;

  LiveGiftItemResponse({
    this.id,
    this.name,
    this.imageUrl,
    this.animationUrl,
    this.diamondCost,
  });

  factory LiveGiftItemResponse.fromJson(Map<String, dynamic> json) =>
      _$LiveGiftItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LiveGiftItemResponseToJson(this);
}
