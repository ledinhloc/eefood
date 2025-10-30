import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/profile/presentation/widgets/about_tab.dart';
import 'package:eefood/features/profile/presentation/widgets/personal_recipe_tab.dart';
import 'package:eefood/features/profile/presentation/widgets/personal_user_header.dart';
import 'package:eefood/features/profile/presentation/widgets/profile_tab_bar.dart';
import 'package:eefood/features/recipe/presentation/widgets/recipe_tab.dart';
import 'package:flutter/material.dart';

class PersonalUserPage extends StatefulWidget {
  const PersonalUserPage({super.key});

  @override
  State<PersonalUserPage> createState() => _PersonalUserPageState();
}

class _PersonalUserPageState extends State<PersonalUserPage>
    with SingleTickerProviderStateMixin {
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();
  User? user;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _loadUser() async {
    user = await _getCurrentUser();
    print(user?.avatarUrl);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Personal Profile'),
        centerTitle: true,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                PersonalUserHeader(user: user),
                ProfileTabBar(tabController: _tabController),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          physics:
              const NeverScrollableScrollPhysics(), 
          children: [
            PersonalRecipeTab(),
            AboutTab(),
          ],
        ),
      ),
    );
  }
}
