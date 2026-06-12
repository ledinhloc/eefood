import 'package:eefood/features/payment/data/model/wallet_history_response.dart';

class WalletHistoryState {
  final List<WalletHistoryResponse> histories;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? filterType;
  final String sort;
  final String? error;

  const WalletHistoryState({
    this.histories = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.filterType,
    this.sort = 'newest',
    this.error,
  });

  WalletHistoryState copyWith({
    List<WalletHistoryResponse>? histories,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? sort,
    Object? filterType = _sentinel,
    Object? error = _sentinel,
  }) {
    return WalletHistoryState(
      histories: histories ?? this.histories,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filterType: filterType == _sentinel
          ? this.filterType
          : filterType as String?,
      sort: sort ?? this.sort,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
