sealed class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String paymentUrl;
  final int transactionId;
  PaymentSuccess({required this.paymentUrl, required this.transactionId});
}

class PaymentFailure extends PaymentState {
  final String message;
  PaymentFailure({required this.message});
}
