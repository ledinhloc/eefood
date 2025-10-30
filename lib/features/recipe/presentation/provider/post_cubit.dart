import 'package:eefood/features/recipe/presentation/provider/post_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import '../../domain/repositories/post_publish_repository.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/post_publish_model.dart';

class PostCubit extends Cubit<PostState> {
  final PostPublishRepository _postRepository = getIt<PostPublishRepository>();

  PostCubit() : super(PostState.initial());

  /// Lấy danh sách các post đã published
  Future<void> fetchPublishedPosts() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final posts = await _postRepository.getPublishedPosts();
      emit(state.copyWith(isLoading: false, posts: posts));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Tạo post mới
  Future<void> createPost(
      BuildContext context, int recipeId, String content) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final post = await _postRepository.createPost(recipeId, content);

      // thêm vào danh sách hiện tại
      final updated = List<PostPublishModel>.from(state.posts)..insert(0, post);

      emit(state.copyWith(isLoading: false, posts: updated));
      showCustomSnackBar(context, "✅ Published successfully");
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      showCustomSnackBar(context, "❌ Publish failed: $e", isError: true);
    }
  }

  /// Cập nhật post
  Future<void> updatePost(
      BuildContext context, int postId, String content) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final updatedPost = await _postRepository.updatePost(postId, content);

      final updatedList = state.posts.map((p) {
        return p.id == postId ? updatedPost : p;
      }).toList();

      emit(state.copyWith(isLoading: false, posts: updatedList));
      showCustomSnackBar(context, "✅ Post updated");
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      showCustomSnackBar(context, "❌ Update failed: $e", isError: true);
    }
  }

  ///Xóa post
  Future<void> deletePost(BuildContext context, int postId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _postRepository.deletePost(postId);
      final remaining = state.posts.where((p) => p.id != postId).toList();

      emit(state.copyWith(isLoading: false, posts: remaining, deleted: true));
      showCustomSnackBar(context, "✅ Post deleted");
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      showCustomSnackBar(context, "❌ Delete failed: $e", isError: true);
    }
  }

  void reset() => emit(PostState.initial());
}
