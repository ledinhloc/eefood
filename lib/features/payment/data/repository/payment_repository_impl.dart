import 'package:dio/dio.dart';
import 'package:eefood/core/utils/logger.dart';
import 'package:eefood/features/payment/data/model/create_payment_request.dart';
import 'package:eefood/features/payment/data/model/create_payment_response.dart';
import 'package:eefood/features/payment/data/model/diamond_package_response.dart';
import 'package:eefood/features/payment/domain/repository/payment_repository.dart';

class PaymentRepositoryImpl extends PaymentRepository {
  final Dio dio;

  PaymentRepositoryImpl({required this.dio});

  @override
  Future<CreatePaymentResponse?> createPayment(CreatePaymentRequest request) async {
    try {
      final response = await dio.post('/v1/payment/create',data: request.toJson());

      final json = response.data['data'];
      if(response.statusCode==200 && json !=null) {
        return CreatePaymentResponse.fromJson(json);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create payment');
    }
  }

  @override
  Future<List<DiamondPackageResponse>> getListDiamondPackages() async {
    try {
      final response = await dio.get('/v1/payment/get-package');
      final data = response.data['data'] as List;
      logger.i("Data: $data");
      if (response.statusCode == 200) {
        return data
            .map((json) => DiamondPackageResponse.fromJson(json))
            .toList();
      }
      return List.empty();
    } catch (e) {
      throw Exception('Failed to get list diamond packages');
    }
  }

  @override
  Future<int> getBalance(int userId) async {
    try {
      final response = await dio.get('/v1/payment/wallet/$userId');
      final data = response.data['data'] as int;
      return data;
    } catch (e) {
      throw Exception('Failed to get balance $e');
    }
  }
}
