// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletHistoryResponse _$WalletHistoryResponseFromJson(
        Map<String, dynamic> json) =>
    WalletHistoryResponse(
      id: json['id'] as num?,
      userId: json['userId'] as num?,
      transactionId: json['transactionId'] as num?,
      type: json['type'] as String?,
      amount: json['amount'] as num?,
      balanceBefore: json['balanceBefore'] as num?,
      balanceAfter: json['balanceAfter'] as num?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WalletHistoryResponseToJson(
        WalletHistoryResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'transactionId': instance.transactionId,
      'type': instance.type,
      'amount': instance.amount,
      'balanceBefore': instance.balanceBefore,
      'balanceAfter': instance.balanceAfter,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
