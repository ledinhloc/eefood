import '../enum/activity_level.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? dob;
  final String? gender;
  final Address? address;
  final String provider;
  final String? avatarUrl;
  final String? backgroundUrl;
  final ActivityLevel? activityLevel;
  final List<String>? allergies;
  final List<String>? eatingPreferences;
  final List<String>? dietaryPreferences;
  final List<String>? healthConditions;

  const User({
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
  });
}

class Address {
  final String city;
  final String street;

  const Address({required this.city, required this.street});
}
