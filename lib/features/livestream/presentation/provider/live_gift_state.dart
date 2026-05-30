import 'package:eefood/features/livestream/data/model/live_gift_item_response.dart';
import 'package:eefood/features/livestream/data/model/send_gift_response.dart';
enum GiftSendStatus { idle, sending, success, error }

class LiveGiftState {
  final List<LiveGiftItemResponse> gifts;
  final bool isLoading;
  final String? error;

  final LiveGiftItemResponse? selectedGift;
  final int quantity;

  final GiftSendStatus sendStatus;
  final String? sendError;

  final List<SendGiftResponse> incomingGifts;

  const LiveGiftState({
    this.gifts = const [],
    this.isLoading = false,
    this.error,
    this.selectedGift,
    this.quantity = 1,
    this.sendStatus = GiftSendStatus.idle,
    this.sendError,
    this.incomingGifts = const [],
  });

  LiveGiftState copyWith({
    List<LiveGiftItemResponse>? gifts,
    bool? isLoading,
    String? error,
    LiveGiftItemResponse? selectedGift,
    bool clearSelectedGift = false,
    int? quantity,
    GiftSendStatus? sendStatus,
    String? sendError,
    bool clearSendError = false,
    List<SendGiftResponse>? incomingGifts,
  }) {
    return LiveGiftState(
      gifts: gifts ?? this.gifts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedGift: clearSelectedGift
          ? null
          : (selectedGift ?? this.selectedGift),
      quantity: quantity ?? this.quantity,
      sendStatus: sendStatus ?? this.sendStatus,
      sendError: clearSendError ? null : (sendError ?? this.sendError),
      incomingGifts: incomingGifts ?? this.incomingGifts,
    );
  }

  /// Tổng chi phí dựa trên quà đang chọn và số lượng
  int get totalCost => (selectedGift?.diamondCost ?? 0) * quantity;

  bool canAfford(int balance) => balance >= totalCost;
}