import 'package:eefood/features/recipe/presentation/provider/post_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import '../../domain/repositories/post_repository.dart';
import '../../../../core/di/injection.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository _postRepository = getIt<PostRepository>();

  PostCubit() : super(PostState.initial());

  Future<void> createPost(BuildContext context, int recipeId, String content) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final post = await _postRepository.createPost(recipeId, content);
      emit(state.copyWith(isLoading: false, post: post));
      showCustomSnackBar(context, "✅ Published successfully");
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      showCustomSnackBar(context, "❌ Publish failed: $e", isError: true);
    }
  }

  Future<void> updatePost(BuildContext context, int postId, String content) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final post = await _postRepository.updatePost(postId, content);
      emit(state.copyWith(isLoading: false, post: post));
      showCustomSnackBar(context, "✅ Post updated");
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      showCustomSnackBar(context, "❌ Update failed: $e", isError: true);
    }
  }

  Future<void> deletePost(BuildContext context, int postId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _postRepository.deletePost(postId);
      emit(state.copyWith(isLoading: false, deleted: true));
      showCustomSnackBar(context, "✅ Post deleted");
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      showCustomSnackBar(context, "❌ Delete failed: $e", isError: true);
    }
  }

  void reset() => emit(PostState.initial());
}
