import 'package:eefood/features/recipe_review/data/models/question_state_model.dart';
import 'package:eefood/features/recipe_review/data/models/recipe_review_stats_model.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/stat_detail/navigation_bar.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/stat_detail/question_progress.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/stat_detail/question_stats_card.dart';
import 'package:flutter/material.dart';

class ReviewStatsDetailScreen extends StatefulWidget {
  final RecipeReviewStatsModel stats;
  const ReviewStatsDetailScreen({super.key, required this.stats});

  @override
  State<ReviewStatsDetailScreen> createState() =>
      _ReviewStatsDetailScreenState();
}

class _ReviewStatsDetailScreenState extends State<ReviewStatsDetailScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  int? _touchedIndex;

  List<QuestionStateModel> get questions => widget.stats.questionStats ?? [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= questions.length) return;
    setState(() {
      _currentIndex = index;
      _touchedIndex = null;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Chi tiết đánh giá",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: questions.isEmpty
          ? Center(
              child: Text(
                "Không có dữ liệu",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            )
          : Column(
              children: [
                // Progress indicator
                QuestionProgress(
                  current: _currentIndex,
                  total: questions.length,
                ),

                // PageView questions
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: questions.length,
                    itemBuilder: (_, index) {
                      final q = questions[index];
                      return QuestionStatsCard(
                        question: q,
                        touchedIndex: index == _currentIndex
                            ? _touchedIndex
                            : null,
                        onTouch: (i) => setState(() => _touchedIndex = i),
                      );
                    },
                  ),
                ),

                // Navigation buttons
                NavigationBarReview(
                  current: _currentIndex,
                  total: questions.length,
                  onPrev: () => _goTo(_currentIndex - 1),
                  onNext: () => _goTo(_currentIndex + 1),
                ),
              ],
            ),
    );
  }
}
