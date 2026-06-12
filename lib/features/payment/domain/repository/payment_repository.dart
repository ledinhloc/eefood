import 'package:eefood/features/payment/data/model/create_payment_request.dart';
import 'package:eefood/features/payment/data/model/create_payment_response.dart';
import 'package:eefood/features/payment/data/model/diamond_package_response.dart';
import 'package:eefood/features/payment/data/model/wallet_history_response.dart';

abstract class PaymentRepository {
  Future<List<WalletHistoryResponse>>  getHistory(num userId, String? type, {String sort='newest', int page=0, int size=10});
  Future<CreatePaymentResponse?> createPayment(CreatePaymentRequest request);
  Future<List<DiamondPackageResponse>> getListDiamondPackages();
  Future<int> getBalance(int userId);
}
