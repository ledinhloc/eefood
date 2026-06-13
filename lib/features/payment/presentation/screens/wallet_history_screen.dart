import 'package:eefood/features/payment/presentation/provider/wallet_history_cubit.dart';
import 'package:eefood/features/payment/presentation/provider/wallet_history_state.dart';
import 'package:eefood/features/payment/presentation/widgets/filter_chip.dart';
import 'package:eefood/features/payment/presentation/widgets/history_card.dart';
import 'package:eefood/features/payment/presentation/widgets/sort_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletHistoryScreen extends StatefulWidget {
  final num userId;
  final String userName;
  const WalletHistoryScreen({super.key, required this.userId, required this.userName});

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  late final ScrollController _scrollController;
  late final WalletHistoryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<WalletHistoryCubit>();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.fetchHistory(userId: widget.userId);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.fetchHistory(userId: widget.userId, loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          const Text(
            'Lịch sử giao dịch',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          BlocBuilder<WalletHistoryCubit, WalletHistoryState>(
            builder: (_, state) => Text(
              '${widget.userName}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildFilterBar() {
    return BlocBuilder<WalletHistoryCubit, WalletHistoryState>(
      builder: (_, state) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // --- Loại giao dịch ---
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChipPayemnt(
                        label: 'Tất cả',
                        isSelected: state.filterType == null,
                        color: Colors.blueGrey,
                        onTap: () => _cubit.changeFilter(
                          userId: widget.userId,
                          filterType: null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      FilterChipPayemnt(
                        label: 'Nạp',
                        isSelected: state.filterType == 'TOPUP',
                        color: Colors.green,
                        onTap: () => _cubit.changeFilter(
                          userId: widget.userId,
                          filterType: 'TOPUP',
                        ),
                      ),
                      const SizedBox(width: 6),
                      FilterChipPayemnt(
                        label: 'Đã dùng',
                        isSelected: state.filterType == 'SPEND',
                        color: Colors.orange,
                        onTap: () => _cubit.changeFilter(
                          userId: widget.userId,
                          filterType: 'SPEND',
                        ),
                      ),
                      const SizedBox(width: 6),
                      FilterChipPayemnt(
                        label: 'Hoàn trả',
                        isSelected: state.filterType == 'REFUND',
                        color: Colors.blue,
                        onTap: () => _cubit.changeFilter(
                          userId: widget.userId,
                          filterType: 'REFUND',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // --- Sort ---
              SortButton(
                sort: state.sort,
                onToggle: () => _cubit.changeFilter(
                  userId: widget.userId,
                  sort: state.sort == 'newest' ? 'oldest' : 'newest',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return BlocBuilder<WalletHistoryCubit, WalletHistoryState>(
      builder: (_, state) {
        // Lần đầu loading
        if (state.isLoading && state.histories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.histories.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _cubit.fetchHistory(userId: widget.userId),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Thu lai'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty
        if (!state.isLoading && state.histories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 56,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'Chưa có giao dịch nào',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Colors.blue.shade600,
          onRefresh: () => _cubit.fetchHistory(userId: widget.userId),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: state.histories.length + 1,
            itemBuilder: (_, index) {
              if (index == state.histories.length) {
                return state.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : !state.hasMore
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'Đã tải hết giao dịch',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(height: 16);
              }
              return HistoryCard(item: state.histories[index]);
            },
          ),
        );
      },
    );
  }
}
