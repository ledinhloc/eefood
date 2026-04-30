// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewDetailModel _$ReviewDetailModelFromJson(Map<String, dynamic> json) =>
    ReviewDetailModel(
      reviewId: (json['reviewId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ReviewDetailModelToJson(ReviewDetailModel instance) =>
    <String, dynamic>{
      'reviewId': instance.reviewId,
      'userId': instance.userId,
      'name': instance.name,
      'avatar': instance.avatar,
      'rating': instance.rating,
      'createdAt': instance.createdAt?.toIso8601String(),
      'tags': instance.tags,
    };
