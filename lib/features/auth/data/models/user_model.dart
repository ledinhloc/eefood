import 'package:json_annotation/json_annotation.dart';

import '../../domain/enum/activity_level.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? dob;
  final String? gender;
  @JsonKey(name: 'address')
  final AddressModel? address;
  final String provider;
  final String? avatarUrl;
  final String? backgroundUrl;
  final ActivityLevel? activityLevel;
  final List<String>? allergies;
  final List<String>? eatingPreferences;
  final List<String>? dietaryPreferences;
  final List<String>? healthConditions;

  final String? accessToken;

  final String? refreshToken;
  final String? fcmToken;
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.dob,
    this.gender,
    this.address,
    required this.provider,
    this.avatarUrl,
    this.backgroundUrl,
    this.activityLevel,
    this.allergies,
    this.eatingPreferences,
    this.dietaryPreferences,
    this.healthConditions,
    this.accessToken,
    this.refreshToken,
    this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /* Chuyen user thanh json */
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(
    id: id,
    username: username,
    email: email,
    role: role,
    dob: dob,
    gender: gender,
    address: address?.toEntity(),
    provider: provider,
    avatarUrl: avatarUrl,
    backgroundUrl: backgroundUrl,
    activityLevel: activityLevel,
    allergies: allergies,
    eatingPreferences: eatingPreferences,
    dietaryPreferences: dietaryPreferences,
    healthConditions: healthConditions,
  );
}

@JsonSerializable()
class AddressModel {
  final String city;
  final String street;

  AddressModel({required this.city, required this.street});

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  /* Chuyen address thanh json*/
  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  Address toEntity() => Address(city: city, street: street);
}
