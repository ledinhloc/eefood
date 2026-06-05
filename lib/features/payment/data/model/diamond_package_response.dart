import 'package:json_annotation/json_annotation.dart';

part 'diamond_package_response.g.dart';

@JsonSerializable()
class DiamondPackageResponse {
  final int? id;
  final int? diamondAmount;
  final int? bonusDiamond;
  final num? price;
  final String? currency;
  final bool? isActive;

  DiamondPackageResponse({
    this.id,
    this.diamondAmount,
    this.bonusDiamond,
    this.price,
    this.currency,
    this.isActive,
  });

  factory DiamondPackageResponse.fromJson(Map<String, dynamic> json) =>
      _$DiamondPackageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DiamondPackageResponseToJson(this);
}
