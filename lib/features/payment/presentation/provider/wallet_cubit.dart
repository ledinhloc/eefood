import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/livestream/presentation/provider/livestream_websocket_manager.dart';
import 'package:eefood/features/payment/domain/repository/payment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletCubit extends Cubit<int> {
  final PaymentRepository repository;
  final LiveStreamWebSocketManager _wsManager =
      getIt<LiveStreamWebSocketManager>();

  int? _cachedUserId;

  WalletCubit({required this.repository}) : super(0);

  Future<void> init(int userId) async {
    final balance = await repository.getBalance(userId);
    emit(balance);

    _wsManager.connect(
      logName: 'DiamondBalance',
      onConnected: () => _subscribeBalance(),
    );
  }

  void _subscribeBalance() {
    _wsManager.subscribeUserQueue<int>(
      queue: 'wallet-balance',
      fromJson: (json) => (json['balance'] as num).toInt(),
      onData: emit,
      logName: 'DiamondBalance',
      logPrefix: 'balance update',
    );
  }

  void setBalance(int newBalance) {
    if (isClosed) return;
    emit(newBalance);
  }

  Future<void> fetchBalance() async {
    final userId = _cachedUserId;
    if (userId == null || isClosed) return;
    try {
      final balance = await repository.getBalance(userId);
      if (!isClosed) emit(balance);
    } catch (_) {
      // Giữ balance cũ, không crash
    }
  }

  @override
  Future<void> close() {
    _wsManager.unsubscribeUserQueue(
      queue: 'wallet-balance',
      logName: 'DiamondBalance',
    );
    return super.close();
  }
}
