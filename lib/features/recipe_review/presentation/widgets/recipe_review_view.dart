import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/recipe_review/presentation/provider/review_recipe_cubit.dart';
import 'package:eefood/features/recipe_review/presentation/provider/review_recipe_state.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/question_card/review_question_card.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/review_header.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/review_progress_bar.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/submit_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeReviewView extends StatelessWidget {
  final int recipeId;
  const RecipeReviewView({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewRecipeCubit, RecipeReviewState>(
      listener: (context, state) {
        if (state.status == RecipeReviewStatus.error && state.error != null) {
          showCustomSnackBar(context, state.error!, isError: true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: SafeArea(child: _buildBody(context, state)),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RecipeReviewState state) {
    if (state.status == RecipeReviewStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
      );
    }

    if (state.status == RecipeReviewStatus.error && state.questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 48),
            const SizedBox(height: 12),
            Text(
              state.error ?? 'Có lỗi xảy ra',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<ReviewRecipeCubit>().loadQuestions(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final isSubmitting = state.status == RecipeReviewStatus.submitting;

    return Column(
      children: [
        // Header
        ReviewHeader(onSkip: () => Navigator.of(context).pop()),

        // Progress bar
        ReviewProgressBar(
          answered: state.selectedOptions.length,
          total: state.questions.length,
        ),

        // Questions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              final question = state.questions[index];
              final selectedOptionId = question.id != null
                  ? state.selectedOptions[question.id]
                  : null;
              return ReviewQuestionCard(
                index: index,
                question: question,
                selectedOptionId: selectedOptionId,
                onOptionSelected: (optionId) {
                  if (question.id != null) {
                    context.read<ReviewRecipeCubit>().selectOption(
                      question.id!,
                      optionId,
                    );
                  }
                },
              );
            },
          ),
        ),

        // Submit button
        SubmitSection(
          isAllAnswered: state.isAllAnswered,
          isSubmitting: isSubmitting,
          answeredCount: state.selectedOptions.length,
          totalCount: state.questions.length,
          onSubmit: () {
            context.read<ReviewRecipeCubit>().submitReview(recipeId);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
