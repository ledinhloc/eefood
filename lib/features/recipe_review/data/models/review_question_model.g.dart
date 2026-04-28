// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewQuestionModel _$ReviewQuestionModelFromJson(Map<String, dynamic> json) =>
    ReviewQuestionModel(
      id: (json['id'] as num?)?.toInt(),
      content: json['content'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => ReviewOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReviewQuestionModelToJson(
        ReviewQuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'weight': instance.weight,
      'isActive': instance.isActive,
      'options': instance.options,
    };
