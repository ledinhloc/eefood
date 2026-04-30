// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_review_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeReviewStatsModel _$RecipeReviewStatsModelFromJson(
        Map<String, dynamic> json) =>
    RecipeReviewStatsModel(
      avgRating: (json['avgRating'] as num?)?.toDouble(),
      totalReviews: (json['totalReviews'] as num?)?.toInt(),
      ratingDistribution:
          (json['ratingDistribution'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      questionStats: (json['questionStats'] as List<dynamic>?)
          ?.map((e) => QuestionStateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => ReviewDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecipeReviewStatsModelToJson(
        RecipeReviewStatsModel instance) =>
    <String, dynamic>{
      'avgRating': instance.avgRating,
      'totalReviews': instance.totalReviews,
      'ratingDistribution':
          instance.ratingDistribution?.map((k, e) => MapEntry(k.toString(), e)),
      'questionStats': instance.questionStats,
      'reviews': instance.reviews,
    };
