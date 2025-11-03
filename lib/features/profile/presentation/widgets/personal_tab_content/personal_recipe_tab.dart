import 'package:eefood/core/widgets/post_skeletion_loading.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/widgets/post/reaction_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';
import 'package:eefood/features/post/presentation/widgets/post/post_card.dart';

class PersonalRecipeTab extends StatefulWidget {
  final User user;
  const PersonalRecipeTab({super.key, required this.user});

  @override
  State<PersonalRecipeTab> createState() => _PersonalRecipeTabState();
}

class _PersonalRecipeTabState extends State<PersonalRecipeTab> {
  late final PostListCubit _cubit;
  OverlayEntry? _activePopup;

  @override
  void initState() {
    super.initState();
    // Tạo instance riêng cho tab này, không dùng chung với FeedScreen
    _cubit = PostListCubit()..fetchOwnPost(userId: widget.user.id);
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
    _cubit.close(); // Đóng cubit khi dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<PostListCubit, PostListState>(
        builder: (context, state) {
          if (state.isLoading && state.posts.isEmpty) {
            return const PostSkeletonList(itemCount: 10);
          }

          if (state.posts.isEmpty) {
            return const Center(child: Text('Người dùng chưa đăng bài nào.'));
          }

          return RefreshIndicator(
            onRefresh: () async =>
                _cubit.fetchOwnPost(userId: widget.user.id, loadMore: false),
            child: CustomScrollView(
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
