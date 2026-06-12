import 'package:json_annotation/json_annotation.dart';

part 'wallet_history_response.g.dart';

@JsonSerializable()
class WalletHistoryResponse {
  final num? id;
  final num? userId;
  final num? transactionId;
  final String? type;
  final num? amount;
  final num? balanceBefore;
  final num? balanceAfter;
  final DateTime? createdAt;

  WalletHistoryResponse({
    this.id,
    this.userId,
    this.transactionId,
    this.type,
    this.amount,
    this.balanceBefore,
    this.balanceAfter,
    this.createdAt,
  });

  factory WalletHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WalletHistoryResponseToJson(this);
}
