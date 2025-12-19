import 'package:eefood/core/widgets/post_skeletion_loading.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/post/post_card.dart';
import 'package:eefood/features/post/presentation/widgets/post/reaction_popup.dart';
import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalRecipeTab extends StatefulWidget {
  final User user;
  const PersonalRecipeTab({super.key, required this.user});

  @override
  State<PersonalRecipeTab> createState() => _PersonalRecipeTabState();
}

class _PersonalRecipeTabState extends State<PersonalRecipeTab>
    with AutomaticKeepAliveClientMixin {
  late PostListCubit _cubit;
  late ScrollController _scrollController;
  OverlayEntry? _activePopup;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cubit = PostListCubit();

    _cubit.fetchOwnPost(userId: widget.user.id);

    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom && !_cubit.state.isLoading && _cubit.state.hasMore) {
      _cubit.fetchOwnPost(userId: widget.user.id, loadMore: true);
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void hideReactionPopup() {
    _activePopup?.remove();
    _activePopup = null;
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
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    hideReactionPopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Cần cho AutomaticKeepAliveClientMixin

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<PostListCubit, PostListState>(
        builder: (context, state) {
          if (state.isLoading && state.posts.isEmpty) {
            return const PostSkeletonList(itemCount: 10);
          }

          if (state.posts.isEmpty && !state.isLoading) {
            return const Center(child: Text('Người dùng chưa đăng bài nào.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _cubit.fetchOwnPost(userId: widget.user.id);
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final post = state.posts[index];
                        return PostCard(
                          userId: widget.user.id,
                          post: post,
                          isGuest: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailPage(recipeId: post.recipeId!),
                              ),
                            );
                          },
                          onShowReactions: (offset, callback) =>
                              showReactionPopup(context, offset, callback),
                        );
                      },
                      childCount:
                          state.posts.length + (state.isLoading ? 1 : 0),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
