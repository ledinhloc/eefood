// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionStateModel _$QuestionStateModelFromJson(Map<String, dynamic> json) =>
    QuestionStateModel(
      questionId: (json['questionId'] as num?)?.toInt(),
      content: json['content'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => OptionStateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuestionStateModelToJson(QuestionStateModel instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'content': instance.content,
      'weight': instance.weight,
      'options': instance.options,
    };
