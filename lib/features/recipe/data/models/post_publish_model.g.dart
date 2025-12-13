// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_publish_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostPublishModel _$PostPublishModelFromJson(Map<String, dynamic> json) =>
    PostPublishModel(
      id: (json['id'] as num).toInt(),
      recipeId: (json['recipeId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      difficulty: json['difficulty'] as String?,
      location: json['location'] as String?,
      prepTime: json['prepTime'] as String?,
      cookTime: json['cookTime'] as String?,
      countReaction: (json['countReaction'] as num?)?.toInt(),
      countComment: (json['countComment'] as num?)?.toInt(),
      status: $enumDecode(_$PostStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$PostPublishModelToJson(PostPublishModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipeId': instance.recipeId,
      'userId': instance.userId,
      'title': instance.title,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'difficulty': instance.difficulty,
      'location': instance.location,
      'prepTime': instance.prepTime,
      'cookTime': instance.cookTime,
      'countReaction': instance.countReaction,
      'countComment': instance.countComment,
      'status': _$PostStatusEnumMap[instance.status]!,
    };

const _$PostStatusEnumMap = {
  PostStatus.pending: 'PENDING',
  PostStatus.approved: 'APPROVED',
  PostStatus.rejected: 'REJECTED',
};
