
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/noti/presentation/provider/notification_cubit.dart';
import 'package:eefood/features/noti/presentation/provider/notification_state.dart';
import 'package:eefood/features/noti/presentation/screens/notification_screen.dart';

import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../provider/post_list_cubit.dart';
import '../widgets/post_card.dart';
import 'package:badges/badges.dart' as badges;


class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PostListCubit()..fetchPosts()),
        // DÙNG .value với singleton getIt
        BlocProvider.value(value: getIt<NotificationCubit>()),
      ],
      child: FeedView(),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    final cubit = context.read<NotificationCubit>();
    cubit.fetchUnreadCount();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<PostListCubit>().fetchPosts(loadMore: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Feed 🍽️'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    final cubit = context.read<NotificationCubit>();
                    // Mở trang thông báo
                    print('➡️ Feed pushing cubit hash=${state.hashCode}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child:  NotificationScreen(),
                        ),
                      ),
                    );
                  },
                  child: badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -4, end: -4),
                    showBadge: state.unreadCount > 0, // ẩn/hiện badge
                    badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                    badgeContent: Text(
                      '${state.unreadCount}',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: const Icon(Icons.notifications_none_rounded, size: 28),
                  ),
                );
              },
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<PostListCubit, PostListState>(
        builder: (context, state) {
          if (state.isLoading && state.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.posts.isEmpty) {
            return const Center(child: Text('Không có bài viết nào.'));
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<PostListCubit>().fetchPosts(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.posts.length + (state.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final post = state.posts[index];
                return PostCard(
                  post: post,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailPage(recipeId: post.recipeId!),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
