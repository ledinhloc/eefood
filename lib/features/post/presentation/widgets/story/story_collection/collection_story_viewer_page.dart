import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/post/data/models/story_collection_model.dart';
import 'package:eefood/features/post/data/models/story_model.dart';
import 'package:eefood/features/post/data/models/user_story_model.dart';
import 'package:eefood/features/post/domain/repositories/story_collection_repository.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_list_cubit.dart';
import 'package:eefood/features/post/presentation/provider/story_viewer_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_page.dart/story_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollectionStoryViewerPage extends StatefulWidget {
  final StoryCollectionModel collection;
  final User user;
  final int currentUserId;

  const CollectionStoryViewerPage({
    super.key,
    required this.collection,
    required this.user,
    required this.currentUserId,
  });

  @override
  State<CollectionStoryViewerPage> createState() =>
      _CollectionStoryViewerPageState();
}

class _CollectionStoryViewerPageState extends State<CollectionStoryViewerPage> {
  final StoryCollectionRepository _repository =
      getIt<StoryCollectionRepository>();

  List<StoryModel>? _stories;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCollectionStories();
  }

  Future<void> _loadCollectionStories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final stories = await _repository.getAllStoryCollections(
        widget.collection.id!,
        widget.user.id,
      );

      debugPrint('Mảng stories: ${stories.length}');

      if (mounted) {
        setState(() {
          _stories = stories;
          _isLoading = false;
        });
        if (stories.isNotEmpty) {
          _navigateToStoryViewer(stories);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        showCustomSnackBar(context, 'Không thể tải story: $e');
      }
    }
  }

  void _navigateToStoryViewer(List<StoryModel> stories) {
    final userStory = UserStoryModel(
      userId: widget.user.id,
      username: widget.user.username,
      avatarUrl: widget.user.avatarUrl,
      stories: stories,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<StoryCubit>()),
            BlocProvider(create: (_) => getIt<StoryViewerCubit>()),
            BlocProvider.value(value: getIt<StoryReactionCubit>()),
            BlocProvider.value(value: getIt<StoryReactionStatsCubit>()),
          ],
          child: StoryViewerPage(
            allUsers: [userStory],
            userIndex: 0,
            currentUserId: widget.currentUserId,
            isCollection: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.collection.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCollectionStories,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_stories == null || _stories!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Danh mục trống',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(); // Should not reach here as we navigate away
  }
}
