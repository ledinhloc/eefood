import 'package:eefood/features/auth/domain/entities/user.dart';

class UserUpdatePreferences {
  final List<String>? allergies;
  final List<String>? eatingPreferences;
  final List<String>? dietaryPreferences;

  UserUpdatePreferences({
    this.allergies,
    this.eatingPreferences,
    this.dietaryPreferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'allergies': allergies,
      'eatingPreferences': eatingPreferences,
      'dietaryPreferences': dietaryPreferences,
    };
  }

}
