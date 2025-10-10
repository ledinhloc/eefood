import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/reaction_type.dart';
import '../provider/post_list_cubit.dart';
import '../widgets/post_card.dart';
import '../widgets/reaction_popup.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostListCubit()..fetchPosts(),
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
  OverlayEntry? _activePopup;

  void hideReactionPopup() {
    _activePopup?.remove();
    _activePopup = null;
  }

  void showReactionPopup(BuildContext context, Offset position, Function(ReactionType) onSelect) {
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
    return Scaffold(
      appBar: AppBar(
          title: const Text('Food Feed 🍽️'),
        automaticallyImplyLeading: false,
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
                      builder: (_) => RecipeDetailPage(recipeId: post.recipeId!),
                    ),
                  ),
                  onShowReactions:(offset, callback) =>
                      showReactionPopup(context, offset, callback),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
