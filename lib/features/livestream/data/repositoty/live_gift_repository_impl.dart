import 'package:dio/dio.dart';
import 'package:eefood/features/livestream/data/model/live_gift_item_response.dart';
import 'package:eefood/features/livestream/data/model/send_gift_request.dart';
import 'package:eefood/features/livestream/data/model/send_gift_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_gift_repository.dart';

class LiveGiftRepositoryImpl extends LiveGiftRepository {
  final Dio dio;
  LiveGiftRepositoryImpl({required this.dio});

  @override
  Future<List<LiveGiftItemResponse>> getAllLiveGift() async {
    try {
      final response = await dio.get('/v1/livestreams/gift');
      final listData = response.data['data'] as List;
      return listData
          .map((json) => LiveGiftItemResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get list gift $e');
    }
  }

  @override
  Future<SendGiftResponse?> sendGift(SendGiftRequest request) async {
    try {
      final response = await dio.post(
        '/v1/livestreams/gift',
        data: request.toJson(),
      );
      final data = response.data['data'];
      if (data == null) {
        return null;
      }
      return SendGiftResponse.fromJson(data);
    } catch (e) {
      throw Exception('Failed to send gift $e');
    }
  }
}
