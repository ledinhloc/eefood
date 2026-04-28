// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_review_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeReviewRequest _$RecipeReviewRequestFromJson(Map<String, dynamic> json) =>
    RecipeReviewRequest(
      questionId: (json['questionId'] as num?)?.toInt(),
      optionId: (json['optionId'] as num?)?.toInt(),
      starValue: (json['starValue'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecipeReviewRequestToJson(
        RecipeReviewRequest instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'optionId': instance.optionId,
      'starValue': instance.starValue,
    };
