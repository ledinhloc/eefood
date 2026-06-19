import 'package:eefood/features/payment/data/model/create_payment_request.dart';
import 'package:eefood/features/payment/domain/repository/payment_repository.dart';
import 'package:eefood/features/payment/presentation/provider/payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentCubit({required this.paymentRepository}) : super(PaymentInitial());

  Future<void> createPayment({
    required int diamondPackageId,
    required String provider,
  }) async {
    emit(PaymentLoading());
    try {
      final request = CreatePaymentRequest(
        diamondPackageId: diamondPackageId,
        provider: provider,
      );
      final response = await paymentRepository.createPayment(request);
      if (response != null && response.paymentUrl != null) {
        emit(
          PaymentSuccess(
            paymentUrl: response.paymentUrl,
            transactionId: response.transactionId ?? 0,
          ),
        );
      } else {
        emit(PaymentFailure(message: 'Không thể tạo giao dịch'));
      }
    } catch (e) {
      emit(PaymentFailure(message: e.toString()));
    }
  }

  void reset() => emit(PaymentInitial());
}
