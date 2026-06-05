// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePaymentRequest _$CreatePaymentRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePaymentRequest(
      diamondPackageId: (json['diamondPackageId'] as num?)?.toInt(),
      provider: json['provider'] as String?,
    );

Map<String, dynamic> _$CreatePaymentRequestToJson(
        CreatePaymentRequest instance) =>
    <String, dynamic>{
      'diamondPackageId': instance.diamondPackageId,
      'provider': instance.provider,
    };
