import 'package:dio/dio.dart';
import 'package:eefood/features/payment/domain/repository/payment_repository.dart';

class PaymentRepositoryImpl extends PaymentRepository {
  final Dio dio;

  PaymentRepositoryImpl({required this.dio});

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
