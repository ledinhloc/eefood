// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] == null
          ? null
          : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
      provider: json['provider'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      backgroundUrl: json['backgroundUrl'] as String?,
      activityLevel:
          $enumDecodeNullable(_$ActivityLevelEnumMap, json['activityLevel']),
      allergies: (json['allergies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      eatingPreferences: (json['eatingPreferences'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dietaryPreferences: (json['dietaryPreferences'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      healthConditions: (json['healthConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      fcmToken: json['fcmToken'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'role': instance.role,
      'dob': instance.dob,
      'gender': instance.gender,
      'address': instance.address?.toJson(),
      'provider': instance.provider,
      'avatarUrl': instance.avatarUrl,
      'backgroundUrl': instance.backgroundUrl,
      'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel],
      'allergies': instance.allergies,
      'eatingPreferences': instance.eatingPreferences,
      'dietaryPreferences': instance.dietaryPreferences,
      'healthConditions': instance.healthConditions,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'fcmToken': instance.fcmToken,
    };

const _$ActivityLevelEnumMap = {
  ActivityLevel.SEDENTARY: 'SEDENTARY',
  ActivityLevel.LIGHT: 'LIGHT',
  ActivityLevel.MODERATE: 'MODERATE',
  ActivityLevel.ACTIVE: 'ACTIVE',
};

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
      city: json['city'] as String,
      street: json['street'] as String,
    );

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'city': instance.city,
      'street': instance.street,
    };
