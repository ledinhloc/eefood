import 'dart:io';
import 'package:eefood/core/widgets/post_skeletion_loading.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/provider/post_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/post/post_card.dart';
import 'package:eefood/features/post/presentation/widgets/post/reaction_popup.dart';
import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../auth/domain/usecases/auth_usecases.dart';

class ImageSearchResultsSheet extends StatefulWidget {
  final File imageFile;
  final String? keyword;

  const ImageSearchResultsSheet({
    super.key,
    required this.imageFile,
    this.keyword,
  });

  @override
  State<ImageSearchResultsSheet> createState() =>
      _ImageSearchResultsSheetState();
}

class _ImageSearchResultsSheetState extends State<ImageSearchResultsSheet> {
  final ScrollController _scrollController = ScrollController();
  late final PostListCubit _cubit;
  OverlayEntry? _activePopup;
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();
  bool _isGuest = true;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<PostListCubit>();
  }

  @override
  void initState() {
    super.initState();
    _checkGuest();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _cubit.fetchPosts(loadMore: true);
      }
    });
  }

  Future<void> _checkGuest() async {
    final user = await _getCurrentUser();
    if (!mounted) return;
    setState(() {
      _isGuest = user == null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.resetFilters();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        widget.imageFile,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kết quả tìm kiếm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Các món ăn tương tự',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          if (_cubit.state.posts.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Có ${_cubit.state.posts.length} kết quả tìm kiếm với từ khóa: ${widget.keyword}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<PostListCubit, PostListState>(
                  builder: (context, state) {
                    if (state.isLoading && state.posts.isEmpty) {
                      return PostSkeletonList(itemCount: 5);
                    }
                    if (state.posts.isEmpty) {
                      return const Center(
                        child: Text('Không tìm thấy món ăn nào'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await _cubit.fetchPosts(
                          loadMore: false,
                          imageFile: widget.imageFile,
                        );
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            state.posts.length + (state.isLoading ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == state.posts.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final post = state.posts[i];
                          return PostCard(
                            userId: post.userId,
                            post: post,
                            isGuest: _isGuest,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailPage(
                                    recipeId: post.recipeId!,
                                  ),
                                ),
                              );
                            },
                            onShowReactions: (offset, callback) =>
                                showReactionPopup(context, offset, callback),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
