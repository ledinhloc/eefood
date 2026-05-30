import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/data/model/live_gift_item_response.dart';
import 'package:eefood/features/livestream/data/model/send_gift_request.dart';
import 'package:eefood/features/livestream/data/model/send_gift_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_gift_repository.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_state.dart';
import 'package:eefood/features/livestream/presentation/provider/livestream_websocket_manager.dart';
import 'package:eefood/features/payment/presentation/provider/wallet_cubit.dart';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveGiftCubit extends Cubit<LiveGiftState> {
  final LiveGiftRepository repository;
  final LiveStreamWebSocketManager _wsManager =
      getIt<LiveStreamWebSocketManager>();

  int? _liveStreamId;

  LiveGiftCubit({required  this.repository}): super(const LiveGiftState());

  Future<void> init(int liveStreamId) async {
    _liveStreamId = liveStreamId;
    await loadGifts();
    _subscribeGiftBroadcast(liveStreamId);
  }

  Future<void> loadGifts() async {
    emit(state.copyWith(isLoading: true));
    try {
      final gifts = await repository.getAllLiveGift();
      emit(state.copyWith(gifts: gifts, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _subscribeGiftBroadcast(int liveStreamId) {
    _wsManager.connect(
      logName: 'LiveGiftCubit',
      onConnected: () {
        _wsManager.subscribeTopic<SendGiftResponse>(
          liveStreamId: liveStreamId,
          topic: 'live-gift',
          fromJson: SendGiftResponse.fromJson,
          onData: _onGiftReceived,
          logName: 'LiveGiftCubit',
          logPrefix: 'gift',
        );
      },
    );
  }

  void _onGiftReceived(SendGiftResponse gift) {
    developer.log(
      'Gift received: ${gift.giftName} x${gift.quantity} from ${gift.senderName}',
      name: 'LiveGiftCubit',
    );

    final updated = List<SendGiftResponse>.from(state.incomingGifts)..add(gift);
    emit(state.copyWith(incomingGifts: updated));
     try {
      getIt<WalletCubit>().fetchBalance();
    } catch (_) {}
  }

  /// Gọi sau khi animation hiển thị xong để xóa khỏi danh sách
  void removeIncomingGift(SendGiftResponse gift) {
    final updated = state.incomingGifts
        .where((g) => g.giftLogId != gift.giftLogId)
        .toList();
    emit(state.copyWith(incomingGifts: updated));
  }

  void selectGift(LiveGiftItemResponse gift) {
    if (state.selectedGift?.id == gift.id) return;
    emit(state.copyWith(selectedGift: gift, quantity: 1, clearSendError: true));
  }

  void setQuantity(int qty) {
    if (qty < 1 || qty > 99) return;
    emit(state.copyWith(quantity: qty, clearSendError: true));
  }

  void incrementQuantity() => setQuantity(state.quantity + 1);
  void decrementQuantity() => setQuantity(state.quantity - 1);

  Future<void> sendGift(int currentBalance) async {
    final gift = state.selectedGift;
    final liveStreamId = _liveStreamId;

    if (gift == null || liveStreamId == null) return;

    if (!state.canAfford(currentBalance)) {
      emit(state.copyWith(sendError: 'Không đủ kim cương để tặng quà'));
      return;
    }

    emit(
      state.copyWith(sendStatus: GiftSendStatus.sending, clearSendError: true),
    );
    try {
      final response = await repository.sendGift(
        SendGiftRequest(
          giftItemId: gift.id,
          livestreamId: liveStreamId,
          quantity: state.quantity,
        ),
      );

      final newBalance = response!.senderNewBalance;
      if (newBalance != null) {
        try {
          getIt<WalletCubit>().setBalance(newBalance);
        } catch (_) {}
      }

      emit(state.copyWith(sendStatus: GiftSendStatus.success));
      // Reset về idle sau khi success
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isClosed) {
        emit(state.copyWith(sendStatus: GiftSendStatus.idle));
      }
    } catch (e) {
      emit(
        state.copyWith(
          sendStatus: GiftSendStatus.error,
          sendError: 'Gửi quà thất bại. Vui lòng thử lại.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    if (_liveStreamId != null) {
      _wsManager.unsubscribeTopic(
        liveStreamId: _liveStreamId!,
        topic: 'live-gift',
        logName: 'LiveGiftCubit',
      );
    }
    return super.close();
  }
}
