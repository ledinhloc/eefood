import 'package:flutter/material.dart';

class ProfileTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const ProfileTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: const Color(0xFFE67E22),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFFE67E22),
        indicatorWeight: 2,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.grid_on, size: 20), 
            text: 'Bài viết'
          ),
          Tab(
            icon: Icon(Icons.collections_bookmark, size: 20),
            text: 'Bảng tin',
          ),
          Tab(
            icon: Icon(Icons.info_outline, size: 20),
            text: 'Thông tin',
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
