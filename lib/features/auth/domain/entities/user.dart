class User{
  final int id;
  final String username;
  final String email;
  final String role;
  final String dob;
  final String gender;
  final Address address;
  final String provider;
  final String? avatarUrl;
  final List<String> allergies;
  final List<String> eatingPreferences;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.dob,
    required this.gender,
    required this.address,
    required this.provider,
    this.avatarUrl,
    required this.allergies,
    required this.eatingPreferences,
  });
}

class Address{
  final String city;
  final String street;

  const Address({
    required this.city,
    required this.street,
  });
}