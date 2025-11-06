import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/greeting_helper.dart';
import 'package:eefood/core/widgets/post_skeletion_loading.dart';
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
import '../widgets/post/search_popup.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<PostListCubit>()),
        BlocProvider.value(value: getIt<NotificationCubit>()),
      ],
      child: const FeedView(),
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

  Future<void> _showSearchPopup(BuildContext context) async {
    final cubit = getIt<PostListCubit>();
    await cubit.loadRecentKeywords();

    final filters = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) =>
          BlocProvider.value(value: cubit, child: const SearchPopup()),
    );

    if (filters != null) {
      final keyword = filters['keyword'] as String?;
      if (keyword != null && keyword.isNotEmpty) {
        await cubit.saveKeyword(keyword);
      }
      await cubit.setFilters(
        keyword: keyword,
        region: filters['region'] as String?,
        difficulty: filters['difficulty'] as String?,
      );
    }
  }

  void showReactionPopup(
    BuildContext context,
    Offset position,
    Function(ReactionType) onSelect,
  ) {
    hideReactionPopup();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostListCubit>().fetchPosts();
    });
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
        final avatarUrl = user?.avatarUrl;
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
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => _showSearchPopup(context),
              ),

              // ==== Notification badge fixed ====
              BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
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
                    ),
                  );
                },
              ),

              // ==== User avatar ====
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.personalUser,
                      arguments: {'user': user},
                    );
                  },
                  child: CircleAvatar(
                    radius: 17,
                    backgroundImage: avatarUrl != null
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          body: BlocBuilder<PostListCubit, PostListState>(
            builder: (context, state) {
              if (state.isLoading && state.posts.isEmpty) {
                return PostSkeletonList(itemCount: 10);
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
                      userId: post.userId,
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
