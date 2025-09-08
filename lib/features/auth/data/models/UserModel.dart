
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
  final List<String> allergies;
  final List<String> eatingPreferences;

  final String accessToken;

  final String refreshToken;

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
    required this.allergies,
    required this.eatingPreferences,
    required this.accessToken,
    required this.refreshToken,
  });

  // factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      dob: json['dob'] != null ? json['dob'].toString() : null,
      gender: json['gender'] != null ? json['gender'].toString() : null,
      address: json['address'] != null
          ? AddressModel.fromJson(Map<String, dynamic>.from(json['address']))
          : null,
      provider: json['provider'] as String,
      avatarUrl: json['avatarUrl'] != null ? json['avatarUrl'].toString() : null,
      allergies: List<String>.from(json['allergies'] ?? []),
      eatingPreferences: List<String>.from(json['eatingPreferences'] ?? []),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  /* Chuyen user thanh json */
  // Map<String, dynamic> toJson() => _$UserModelToJson(this);
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
      'allergies': allergies,
      'eatingPreferences': eatingPreferences,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

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
    allergies: allergies,
    eatingPreferences: eatingPreferences,
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