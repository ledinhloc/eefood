// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockUserResponse _$BlockUserResponseFromJson(Map<String, dynamic> json) =>
    BlockUserResponse(
      blockedUserId: (json['blockedUserId'] as num).toInt(),
      createAt: json['createAt'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$BlockUserResponseToJson(BlockUserResponse instance) =>
    <String, dynamic>{
      'blockedUserId': instance.blockedUserId,
      'createAt': instance.createAt,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'email': instance.email,
    };
