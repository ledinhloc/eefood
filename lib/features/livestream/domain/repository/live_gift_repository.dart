import 'package:eefood/features/livestream/data/model/live_gift_item_response.dart';
import 'package:eefood/features/livestream/data/model/send_gift_request.dart';
import 'package:eefood/features/livestream/data/model/send_gift_response.dart';

abstract class LiveGiftRepository {
  Future<List<LiveGiftItemResponse>> getAllLiveGift();
  Future<SendGiftResponse?> sendGift(SendGiftRequest request);
}
