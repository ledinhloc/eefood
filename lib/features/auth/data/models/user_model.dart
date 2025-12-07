
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

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
  final List<String>? allergies;
  final List<String>? eatingPreferences;
  final List<String>? dietaryPreferences;

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
    this.allergies,
    this.eatingPreferences,
    this.dietaryPreferences,
    this.accessToken,
    this.refreshToken,
    this.fcmToken
  });

  // factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ,
      email: json['email'],
      role: json['role'] ,
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address'] != null
          ? AddressModel.fromJson(Map<String, dynamic>.from(json['address']))
          : null,
      provider: json['provider'],
      avatarUrl: json['avatarUrl']?.toString(),
      backgroundUrl: json['backgroundUrl']?.toString(),
      allergies: List<String>.from(json['allergies'] ?? []),
      eatingPreferences: List<String>.from(json['eatingPreferences'] ?? []),
      dietaryPreferences: List<String>.from(json['dietaryPreferences'] ?? []),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      fcmToken: json['fcmToken']
    );
  }

  /* Chuyen user thanh json */
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'dob': dob,
      'gender': gender,
      'address': address?.toJson(),
      'provider': provider,
      'avatarUrl': avatarUrl,
      'backgroundUrl': backgroundUrl,
      'allergies': allergies,
      'eatingPreferences': eatingPreferences,
      'dietaryPreferences': dietaryPreferences,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'fcmToken': fcmToken
    };
  }

  User toEntity() => User(
    id: id,
    username: username,
    email: email,
    role: role ,
    dob: dob,
    gender: gender,
    address: address?.toEntity(),
    provider: provider,
    avatarUrl: avatarUrl,
    backgroundUrl: backgroundUrl,
    allergies: allergies,
    eatingPreferences: eatingPreferences,
    dietaryPreferences: dietaryPreferences,
  );
}

class AddressModel {
  final String city;
  final String street;

  AddressModel({required this.city, required this.street});

  /* chuyen thanh AddressModel */
  // factory AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      city: json['city'] != null ? json['city'].toString() : '',
      street: json['street'] != null ? json['street'].toString() : '',
    );
  }

  /* Chuyen address thanh json*/
  // Map<String, dynamic> toJson() => _$AddressModelToJson(this);
  Map<String, dynamic> toJson() {
    return  {
      'city': city,
      'street': street
    };
  }
  Address toEntity() => Address(city: city, street: street);
}