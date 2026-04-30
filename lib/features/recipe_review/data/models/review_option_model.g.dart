// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewOptionModel _$ReviewOptionModelFromJson(Map<String, dynamic> json) =>
    ReviewOptionModel(
      id: (json['id'] as num?)?.toInt(),
      content: json['content'] as String?,
      starValue: (json['starValue'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReviewOptionModelToJson(ReviewOptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'starValue': instance.starValue,
    };
