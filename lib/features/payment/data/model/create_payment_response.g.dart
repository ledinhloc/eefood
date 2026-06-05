// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePaymentResponse _$CreatePaymentResponseFromJson(
        Map<String, dynamic> json) =>
    CreatePaymentResponse(
      transactionId: (json['transactionId'] as num?)?.toInt(),
      provider: $enumDecode(_$TransactionProviderEnumMap, json['provider']),
      paymentUrl: json['paymentUrl'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$CreatePaymentResponseToJson(
        CreatePaymentResponse instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'provider': _$TransactionProviderEnumMap[instance.provider]!,
      'paymentUrl': instance.paymentUrl,
      'status': instance.status,
    };

const _$TransactionProviderEnumMap = {
  TransactionProvider.VNPAY: 'VNPAY',
  TransactionProvider.PAYPAL: 'PAYPAL',
};
