import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../provider/block_user_cubit.dart';
import 'blocked_list_tab.dart';
import 'viewer_list_tab.dart';

class ViewerListBottomSheet extends StatefulWidget {
  const ViewerListBottomSheet({super.key});

  @override
  State<ViewerListBottomSheet> createState() => _ViewerListBottomSheetState();
}

class _ViewerListBottomSheetState extends State<ViewerListBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // load blocked users
    context.read<BlockUserCubit>().loadBlockedUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.72,
      decoration: const BoxDecoration(
        color: Color(0xFF10131A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            _buildHeader(),
            _buildTabBar(),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Colors.white10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [ViewerListTab(), BlockedListTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4DA8FF)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.people_alt_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),

          const Text(
            "Quản lý người xem",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFF6C63FF),
          borderRadius: BorderRadius.circular(11),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.visibility_rounded, size: 18),
                SizedBox(width: 6),
                Text('Người xem'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.block_rounded, size: 18),
                SizedBox(width: 6),
                Text('Đã chặn'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
