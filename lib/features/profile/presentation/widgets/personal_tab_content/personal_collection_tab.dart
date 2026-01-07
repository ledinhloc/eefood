import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/post/presentation/provider/story_collection_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/collection_story_viewer_page.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/dialog/create_update_collection_dialog.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/story_collection_card/story_collection_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalCollectionTab extends StatefulWidget {
  final User user;

  const PersonalCollectionTab({super.key, required this.user});

  @override
  State<PersonalCollectionTab> createState() => _PersonalCollectionTabState();
}

class _PersonalCollectionTabState extends State<PersonalCollectionTab> {
  late StoryCollectionCubit _cubit;
  late ScrollController _scrollController;
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<StoryCollectionCubit>();
    _scrollController = ScrollController()..addListener(_onScroll);

    // Load collections on init
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await _getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUserId = user?.id;
        });
        _cubit.loadCollections(widget.user.id);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = _cubit.state;
      if (!state.isLoadingMore && state.hasMore) {
        _cubit.loadCollections(widget.user.id, loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isOwner =>
      _currentUserId != null && _currentUserId == widget.user.id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<StoryCollectionCubit, StoryCollectionState>(
        builder: (context, state) {
          if (state.isLoading && state.collections.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.collections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.collections_bookmark_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có danh mục nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  if (_isOwner) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: _cubit,
                            child: CreateAndUpdateCollectionDialog(
                              userId: _currentUserId!,
                              collection: null,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Tạo danh mục',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  await _cubit.loadCollections(widget.user.id);
                },
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount:
                      state.collections.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.collections.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final collection = state.collections[index];
                    return StoryCollectionGridCard(
                      currentUserId: _currentUserId ?? 0,
                      collection: collection,
                      onTap: () async {
                        final User? user = await _getCurrentUser();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => StoryCubit(),
                              child: CollectionStoryViewerPage(
                                collection: collection,
                                user: widget.user,
                                currentUserId: user!.id,
                              ),
                            ),
                          ),
                        );
                        if (mounted) {
                          await getIt<StoryCubit>().loadStories(user!.id, isCollection: true);
                        }
                      },
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  shape: CircleBorder(),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: _cubit,
                        child: CreateAndUpdateCollectionDialog(
                          userId: _currentUserId!,
                          collection: null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
