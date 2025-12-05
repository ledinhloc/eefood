import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/post/data/models/story_collection_model.dart';
import 'package:eefood/features/post/presentation/provider/story_collection_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/dialog/confirm_dialog.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/dialog/create_update_collection_dialog.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/empty_collection.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/story_collection_card/story_collection_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryCollectionPage extends StatefulWidget {
  final int userId;
  final int storyId;

  const StoryCollectionPage({
    super.key,
    required this.userId,
    required this.storyId,
  });

  @override
  State<StoryCollectionPage> createState() => _StoryCollectionPageState();
}

class _StoryCollectionPageState extends State<StoryCollectionPage> {
  late StoryCollectionCubit _cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<StoryCollectionCubit>();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadData() async {
    await _cubit.loadCollections(widget.userId);
    await _cubit.loadCollectionsContainingStory(widget.storyId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_cubit.state.isLoadingMore &&
        _cubit.state.hasMore) {
      _cubit.loadCollections(widget.userId, loadMore: true);
    }
  }

  void _showCreateCollectionDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _cubit,
        child: CreateAndUpdateCollectionDialog(userId: widget.userId),
      ),
    );
  }

  Future<void> _handleDeleteCollection(StoryCollectionModel collection) async {
    if (collection.id == null) return;

    final confirm = await CollectionDialogs.showDeleteDialog(
      context,
      collection.name ?? '',
    );

    if (confirm == true) {
      await _cubit.deleteCollection(collection.id!);
    }
  }

  Future<void> _handleCollectionTap(StoryCollectionModel collection) async {
    if (collection.id == null) return;

    final isInCollection = _cubit.isStoryInCollection(collection.id);

    final confirm = isInCollection
        ? await CollectionDialogs.showRemoveStoryDialog(
            context,
            collection.name ?? '',
          )
        : await CollectionDialogs.showAddStoryDialog(
            context,
            collection.name ?? '',
          );

    if (confirm == true) {
      if (isInCollection) {
        await _cubit.removeStoryFromCollection(collection.id!, widget.storyId);
      } else {
        await _cubit.addStoryToCollection(collection.id!, widget.storyId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: BlocConsumer<StoryCollectionCubit, StoryCollectionState>(
          listener: _handleStateChanges,
          builder: _buildBody,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "create_story_collection",
          shape: const CircleBorder(),
          backgroundColor: Colors.red,
          onPressed: _showCreateCollectionDialog,
          elevation: 4,
          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lưu vào danh mục',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            'Chọn danh mục để lưu story',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 70,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey[200], height: 1),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, StoryCollectionState state) {
    if (state.error != null) {
      showCustomSnackBar(context, state.error!, isError: true);
      _cubit.clearMessages();
    }
    if (state.successMessage != null) {
      showCustomSnackBar(context, state.successMessage!);
      _cubit.clearMessages();
    }
  }

  Widget _buildBody(BuildContext context, StoryCollectionState state) {
    if (state.isLoading && state.collections.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.collections.isEmpty) {
      return EmptyCollectionState(onCreatePressed: _showCreateCollectionDialog);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: state.collections.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 0),
        itemBuilder: (context, index) {
          if (state.isLoadingMore && index == state.collections.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final collection = state.collections[index];
          final isInCollection = _cubit.isStoryInCollection(collection.id);

          return CollectionCard(
            collection: collection,
            isStoryInCollection: isInCollection,
            onTap: () => _handleCollectionTap(collection),
            onDelete: () => _handleDeleteCollection(collection),
          );
        },
      ),
    );
  }
}
