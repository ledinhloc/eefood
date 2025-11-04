import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';

import 'package:eefood/features/profile/presentation/widgets/personal_header/personal_user_header.dart';
import 'package:eefood/features/profile/presentation/widgets/personal_tab_content/profile_tab_bar.dart';
import 'package:eefood/features/profile/presentation/widgets/personal_tab_content/info_user/about_tab.dart';
import 'package:eefood/features/profile/presentation/widgets/personal_tab_content/personal_recipe_tab.dart';

class PersonalUserPage extends StatefulWidget {
  final User? user;
  const PersonalUserPage({super.key, required this.user});

  @override
  State<PersonalUserPage> createState() => _PersonalUserPageState();
}

class _PersonalUserPageState extends State<PersonalUserPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          PersonalUserHeader(
            user: widget.user!,
            isScrolled: _scrollOffset > 150,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              PreferredSize(
                preferredSize: const Size.fromHeight(45),
                child: ProfileTabBar(tabController: _tabController),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [PersonalRecipeTab(user: widget.user!,), AboutTab(user: widget.user!,)],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
