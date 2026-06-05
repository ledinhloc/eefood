import 'package:eefood/features/payment/data/model/create_payment_request.dart';
import 'package:eefood/features/payment/data/model/create_payment_response.dart';
import 'package:eefood/features/payment/data/model/diamond_package_response.dart';

abstract class PaymentRepository {
  Future<CreatePaymentResponse?> createPayment(CreatePaymentRequest request);
  Future<List<DiamondPackageResponse>> getListDiamondPackages();
  Future<int> getBalance(int userId);
}
