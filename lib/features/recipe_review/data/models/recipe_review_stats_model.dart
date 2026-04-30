import 'package:eefood/features/recipe_review/data/models/question_state_model.dart';
import 'package:eefood/features/recipe_review/data/models/review_detail_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe_review_stats_model.g.dart';

@JsonSerializable()
class RecipeReviewStatsModel {
  final double? avgRating;
  final int? totalReviews;
  final Map<int, int>? ratingDistribution;
  final List<QuestionStateModel>? questionStats;
  final List<ReviewDetailModel>? reviews;

  RecipeReviewStatsModel({
    this.avgRating,
    this.totalReviews,
    this.ratingDistribution,
    this.questionStats,
    this.reviews,
  });

  factory RecipeReviewStatsModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeReviewStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeReviewStatsModelToJson(this);
}
