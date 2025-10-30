import 'package:flutter/material.dart';

class ProfileTabBar extends StatelessWidget {
  final TabController tabController;

  const ProfileTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 440), // Adjust based on header height
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
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
          Tab(text: 'Recipe'),
          Tab(text: 'About'),
        ],
      ),
    );
  }
}
