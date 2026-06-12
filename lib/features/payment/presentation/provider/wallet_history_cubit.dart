import 'package:eefood/core/utils/logger.dart';
import 'package:eefood/features/payment/domain/repository/payment_repository.dart';
import 'package:eefood/features/payment/presentation/provider/wallet_history_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletHistoryCubit extends Cubit<WalletHistoryState> {
  final PaymentRepository _paymentRepository;

  WalletHistoryCubit(this._paymentRepository)
    : super(const WalletHistoryState());

  void _safeEmit(WalletHistoryState s) {
    if (!isClosed) emit(s);
  }

  Future<void> fetchHistory({
    required num userId,
    bool loadMore = false,
  }) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    _safeEmit(state.copyWith(isLoading: true, error: null));

    final nextPage = loadMore ? state.currentPage + 1 : 1;

    try {
      final items = await _paymentRepository.getHistory(
        userId,
        state.filterType,
        sort: state.sort,
        page: nextPage,
        size: 10,
      );

      logger.i('List history page $nextPage: ${items.length} items');

      _safeEmit(
        state.copyWith(
          histories: loadMore ? [...state.histories, ...items] : items,
          isLoading: false,
          hasMore: items.isNotEmpty && items.length == 10,
          currentPage: nextPage,
        ),
      );
    } catch (e) {
      logger.e('Fetch history error on page $nextPage: $e');
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> changeFilter({
    required num userId,
    String? filterType,
    String? sort,
  }) async {
    _safeEmit(
      state.copyWith(
        filterType: filterType,
        sort: sort ?? state.sort,
        histories: [],
        currentPage: 1,
        hasMore: true,
        error: null,
      ),
    );
    await fetchHistory(userId: userId);
  }
}
