import 'package:json_annotation/json_annotation.dart';

part 'create_payment_response.g.dart';

enum TransactionProvider { VNPAY, PAYPAL }

@JsonSerializable()
class CreatePaymentResponse {
  final int? transactionId;
  final TransactionProvider provider;
  final String paymentUrl;
  final String status;

  CreatePaymentResponse({
    this.transactionId,
    required this.provider,
    required this.paymentUrl,
    required this.status,
  });

  factory CreatePaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentResponseToJson(this);
}
