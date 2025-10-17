import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/greeting_helper.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/noti/presentation/provider/notification_cubit.dart';
import 'package:eefood/features/noti/presentation/provider/notification_state.dart';
import 'package:eefood/features/noti/presentation/screens/notification_screen.dart';
import 'package:eefood/features/post/presentation/widgets/post/reaction_popup.dart';

import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/reaction_type.dart';
import '../provider/post_list_cubit.dart';
import '../widgets/post/post_card.dart';

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
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();
  OverlayEntry? _activePopup;

  void hideReactionPopup() {
    _activePopup?.remove();
    _activePopup = null;
  }

  void showReactionPopup(
    BuildContext context,
    Offset position,
    Function(ReactionType) onSelect,
  ) {
    hideReactionPopup(); // chỉ 1 popup

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _activePopup = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: hideReactionPopup,
        onPanStart: (_) => hideReactionPopup(),
        child: Stack(
          children: [
            Positioned(
              left: position.dx - 40,
              top: position.dy - 80,
              child: Material(
                color: Colors.transparent,
                child: ReactionPopup(
                  onSelect: (reaction) {
                    onSelect(reaction);
                    hideReactionPopup();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_activePopup!);
  }

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
  void dispose() {
    hideReactionPopup();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final userName = user?.username ?? 'bạn';
        final greeting = GreetingHelper.getGreeting(userName: userName);

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                const Text(
                  'Food Feed 🍽️',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () {
                        final cubit = context.read<NotificationCubit>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: cubit,
                              child: const NotificationScreen(),
                            ),
                          ),
                        );
                      },
                      child: badges.Badge(
                        position: badges.BadgePosition.topEnd(top: -8, end: -4),
                        showBadge: state.unreadCount > 0,
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: Colors.red,
                        ),
                        badgeContent: Text(
                          '${state.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
                onRefresh: () async =>
                    context.read<PostListCubit>().fetchPosts(),
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
                          builder: (_) =>
                              RecipeDetailPage(recipeId: post.recipeId!),
                        ),
                      ),
                      onShowReactions: (offset, callback) =>
                          showReactionPopup(context, offset, callback),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
