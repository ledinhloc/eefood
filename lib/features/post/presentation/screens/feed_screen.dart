import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/greeting_helper.dart';
import 'package:eefood/core/widgets/post_skeletion_loading.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/noti/presentation/provider/notification_cubit.dart';
import 'package:eefood/features/noti/presentation/provider/notification_state.dart';
import 'package:eefood/features/noti/presentation/screens/notification_screen.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/post/reaction_popup.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_section.dart';
import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../livestream/presentation/provider/start_live_cubit.dart';
import '../../../livestream/presentation/screens/prepare_live_page.dart';
import '../../data/models/reaction_type.dart';
import '../provider/post_list_cubit.dart';
import '../widgets/post/post_card.dart';
import '../widgets/post/search_popup.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<PostListCubit>()..fetchPosts()),
        BlocProvider.value(value: getIt<NotificationCubit>()),
        BlocProvider.value(value: getIt<StoryCubit>()),
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

  Widget _buildActiveFilters(PostListState state) {
    final hasFilters = state.hasFilters();

    if (!hasFilters) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt, size: 18, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Text(
                'Kết quả tìm kiếm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade900,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.read<PostListCubit>().resetFilters(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Xóa bộ lọc',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (state.keyword != null)
                _buildFilterChip('🔍 ${state.keyword}', () {
                  context.read<PostListCubit>().setFilters(keyword: null);
                }),
              if (state.region != null)
                _buildFilterChip('🌍 ${state.region}', () {
                  context.read<PostListCubit>().setFilters(region: null);
                }),
              if (state.difficulty != null)
                _buildFilterChip(
                  '⚡ ${_getDifficultyLabel(state.difficulty!)}',
                  () {
                    context.read<PostListCubit>().setFilters(difficulty: null);
                  },
                ),
              if (state.category != null)
                _buildFilterChip('🍽️ ${state.category}', () {
                  context.read<PostListCubit>().setFilters(category: null);
                }),
              if (state.maxCookTime != null)
                _buildFilterChip(
                  '⏱️ ${_getCookTimeLabel(state.maxCookTime!)}',
                  () {
                    context.read<PostListCubit>().setFilters(maxCookTime: null);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.orange.shade300),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return difficulty;
    }
  }

  String _getCookTimeLabel(int minutes) {
    if (minutes <= 15) return 'Dưới 15 phút';
    if (minutes <= 30) return 'Dưới 30 phút';
    if (minutes <= 60) return 'Dưới 1 giờ';
    return 'Trên 1 giờ';
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
    print(filters);

    if (filters != null) {
      final keyword = filters['keyword'] as String?;
      if (keyword != null && keyword.isNotEmpty) {
        await cubit.saveKeyword(keyword);
      }
      await cubit.setFilters(
        keyword: keyword,
        region: filters['region'] as String?,
        difficulty: filters['difficulty'] as String?,
        category: filters['category'] as String?,
        maxCookTime: filters['maxCookTime'] as int?,
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await _getCurrentUser();
      if (user != null) {
        await context.read<StoryCubit>().loadStories(user.id);
      }
      await context.read<PostListCubit>().fetchPosts();
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

  Future<void> handleCreateStory(BuildContext context, int? userId) async {
    final storyCubit = context.read<StoryCubit>();
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.galleryPickerPage,
      arguments: {'userId': userId, 'storyCubit': storyCubit},
    );

    if (result == null) return;

    final files = result is List ? result : [result];
    if (files.isEmpty) return;

    try {
      for (final file in files) {
        if (file is! File) continue;
        final isImage =
            file.path.toLowerCase().endsWith('.jpg') ||
            file.path.toLowerCase().endsWith('.jpeg') ||
            file.path.toLowerCase().endsWith('.png') ||
            file.path.toLowerCase().endsWith('.heic');

        await storyCubit.createStory(
          file,
          userId: userId,
          type: isImage ? 'image' : 'video',
        );
      }

      // Reload danh sách story
      await storyCubit.loadStories(userId ?? 0);

      if (context.mounted) {
        showCustomSnackBar(context, "Đã tạo story thành công!");
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(context, "Lỗi khi tạo story", isError: true);
      }
    }
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
            title: GestureDetector(
              onTap: _scrollToTop,
              onDoubleTap: _refreshFeed,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Food Feed 🍽️',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      BlocBuilder<PostListCubit, PostListState>(
                        builder: (context, state) {
                          if (!state.isLoading) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange.shade600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => _showSearchPopup(context),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: getIt<StartLiveCubit>(),
                        child: LivePrepScreen(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.videocam),
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
            builder: (context, postState) {
              // Loading lần đầu
              if (postState.isLoading && postState.posts.isEmpty) {
                return Column(
                  children: [
                    // Story section luôn hiển thị
                    BlocBuilder<StoryCubit, StoryState>(
                      builder: (context, storyState) {
                        return StorySection(
                          onCreateStory: () async {
                            final user = await _getCurrentUser();
                            await handleCreateStory(context, user?.id);
                          },
                          userStories: storyState.stories,
                          currentUserId: user?.id ?? 0,
                          isCreating: storyState.isCreating,
                          onRefresh: () =>
                              context.read<StoryCubit>().loadStories(user!.id),
                        );
                      },
                    ),
                    const Expanded(child: PostSkeletonList(itemCount: 10)),
                  ],
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<PostListCubit>().fetchPosts();
                  await context.read<StoryCubit>().loadStories(user!.id);
                  return;
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildActiveFilters(postState)),
                    // Story Section (an khi co loc)
                    SliverToBoxAdapter(
                      child: postState.hasFilters()
                          ? const SizedBox.shrink()
                          : BlocBuilder<StoryCubit, StoryState>(
                              builder: (context, storyState) {
                                return StorySection(
                                  onCreateStory: () async {
                                    final user = await _getCurrentUser();
                                    await handleCreateStory(context, user?.id);
                                  },
                                  userStories: storyState.stories,
                                  currentUserId: user?.id ?? 0,
                                  isCreating: storyState.isCreating,
                                  onRefresh: () => context
                                      .read<StoryCubit>()
                                      .loadStories(user!.id),
                                );
                              },
                            ),
                    ),

                    // Posts Section
                    if (postState.posts.isEmpty)
                      // Không có posts
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Không có bài viết nào.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // Có posts
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          // Loading indicator ở cuối
                          if (index == postState.posts.length) {
                            return postState.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox(height: 16);
                          }

                          final post = postState.posts[index];
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
                        }, childCount: postState.posts.length + 1),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _scrollToTop() async {
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      HapticFeedback.lightImpact();

      final distance = _scrollController.offset;
      final duration = Duration(
        milliseconds: (distance / 2).clamp(200, 800).toInt(),
      );

      await _scrollController.animateTo(
        0,
        duration: duration,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _refreshFeed() async {
    final postCubit = context.read<PostListCubit>();

    // Kiểm tra isLoading từ cubit
    if (postCubit.state.isLoading) return;

    HapticFeedback.mediumImpact();

    try {
      final user = await _getCurrentUser();

      await Future.wait([
        postCubit.fetchPosts(),
        if (user != null) context.read<StoryCubit>().loadStories(user.id),
      ]);

      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      // if (mounted) {
      //   showCustomSnackBar(context, "Đã làm mới nội dung!");
      // }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, "Lỗi khi tải lại", isError: true);
      }
    }
  }
}
