import 'dart:async';
import 'dart:ui';
import 'package:eefood/features/post/presentation/provider/story_viewer_cubit.dart';

class StoryViewerLoaderHelper {
  Timer? _loadViewerDebounce;
  final StoryViewerCubit cubit;
  final VoidCallback onPause;
  final VoidCallback onResume;

  StoryViewerLoaderHelper({
    required this.cubit,
    required this.onPause,
    required this.onResume,
  });

  void loadViewersForStory(int? storyId, {bool forceReload = false}) {
    if (storyId == null) return;

    onPause();

    _loadViewerDebounce?.cancel();
    _loadViewerDebounce = Timer(const Duration(milliseconds: 300), () async {
      // Reset state riêng cho story hiện tại
      if (forceReload) {
        cubit.resetForStory(storyId);
      }
      // Load viewers của story hiện tại
      await cubit.loadViewer(storyId: storyId);

      onResume();
    });
  }

  void dispose() {
    _loadViewerDebounce?.cancel();
  }
}
