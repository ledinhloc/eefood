import 'package:eefood/features/livestream/presentation/widgets/viewer_list_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../provider/block_user_cubit.dart';
import 'blocked_list_tab.dart';

class ViewerListBottomSheet extends StatefulWidget {
  const ViewerListBottomSheet({Key? key}) : super(key: key);

  @override
  State<ViewerListBottomSheet> createState() =>
      _ViewerListBottomSheetState();
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
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [

          /// HEADER
          _buildHeader(),

          /// TAB BAR
          _buildTabBar(),

          /// TAB VIEW
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ViewerListTab(),
                BlockedListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [

          const Icon(Icons.people, color: Color(0xFFFF6B35)),

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
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Color(0xFFFF6B35),
      labelColor: Color(0xFFFF6B35),
      unselectedLabelColor: Colors.white54,
      tabs: const [
        Tab(text: "Người xem"),
        Tab(text: "Đã chặn"),
      ],
    );
  }
}