class RegisterResponseModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final String provider;

  RegisterResponseModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.provider,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      provider: json['provider'] as String,
    );
  }
}
