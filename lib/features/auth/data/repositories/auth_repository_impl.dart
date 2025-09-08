import 'package:dio/dio.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/features/auth/data/models/otp_model.dart';
import 'package:eefood/features/auth/data/models/register_response_model.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/UserModel.dart';
import 'dart:async';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({required this.dio, required this.sharedPreferences});

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/v1/auth/login',
        data: {'email': email, 'password': password},
        options: Options(contentType: 'application/json'),
      );
      final userModel = UserModel.fromJson(response.data['data']);
      await _saveUser(userModel);

      //print log
      print(response);
      return userModel.toEntity();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = sharedPreferences.getString(AppKeys.refreshToken);
      if (refreshToken != null) {
        await dio.post(
          '/v1/auth/logout',
          data: {'refreshToken': refreshToken},
          options: Options(contentType: 'application/json'),
        );
      }
      await _clearUser();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /* lay user luu trong local*/
  @override
  Future<User?> getCurrentUser() async {
    try {
      final userJson = sharedPreferences.getString(AppKeys.user);
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        return UserModel.fromJson(userMap).toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      final refreshToken = sharedPreferences.getString(AppKeys.refreshToken);
      if (refreshToken != null) {
        final response = await dio.post(
          '/v1/auth/refresh',
          data: {'refreshToken': refreshToken},
          options: Options(contentType: 'application/json'),
        );
        final userModel = UserModel.fromJson(response.data['data']);
        await _saveUser(userModel);
      }
    } catch (e) {
      throw Exception('Refresh token failed: $e');
    }
  }

  @override
  Future<User> getProfile() async {
    try {
      final response = await dio.get(
        '/v1/users/me',
        options: Options(
          contentType: 'application/json',
          headers: {
            'Authorization':
                'Bearer ${sharedPreferences.getString('accessToken')}',
          },
        ),
      );
      final userModel = UserModel.fromJson(response.data['data']);
      await _saveUser(userModel);
      return userModel.toEntity();
    } catch (e) {
      throw Exception('Get profile failed: $e');
    }
  }

  @override
  Future<Result<RegisterResponseModel>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '/v1/auth/register',
        data: {'username': username, 'email': email, 'password': password},
      );
      final json = response.data as Map<String, dynamic>;
      final status = json['status'] as int;
      final message = json['message'] as String;

      if (status >= 200 && status < 300) {
        final model = RegisterResponseModel.fromJson(
          json['data'] as Map<String, dynamic>,
        );
        return Result.success(model);
      } else {
        return Result.failure(message);
      }
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }

  @override
  Future<Result<bool>> verifyOtp(String email, String otpCode, OtpType otpType) async {
    try {
      final response = await dio.post(
        '/v1/auth/verify-otp',
        data: {'email': email, 'otpCode': otpCode, 'otpType': otpType.name},
      );
      final json = response.data as Map<String, dynamic>;
      final status = json['status'] as int;
      final message = json['message'] as String;
      if (status >= 200 && status < 300) {
        return Result.success(true);
      } else {
        return Result.failure(message);
      }
    } catch (e) {
      throw Exception('Verify otp failed: $e');
    }
  }

  @override
  Future<Result<bool>> forgotPassword(String email) async {
    try {
      final response = await dio.post(
        '/v1/auth/forgot-password/request',
        data: {'email': email},
      );
      final json = response.data as Map<String, dynamic>;
      final status = json['status'] as int;
      final message = json['message'] as String;
      if (status >= 200 && status < 300) {
        return Result.success(true);
      } else {
        return Result.failure(message);
      }
    } catch (e) {
      throw Exception('Forgot password failed: $e');
    }
  }

  @override
  Future<Result<bool>> resetPassword(String email, String otpCode, String newPassword) async {
    try {
      final response = await dio.post(
        '/v1/auth/forgot-password/reset',
        data: {'email': email, 'otp': otpCode, 'newPassword': newPassword},
      );
      final json = response.data as Map<String, dynamic>;
      final status = json['status'] as int;
      final message = json['message'] as String;
      if (status >= 200 && status < 300) {
        return Result.success(true);
      } else {
        return Result.failure(message);
      }
    } catch (e) {
      throw Exception('Reset password failed: $e');
    }
  }

  Future<void> _saveUser(UserModel user) async {
    await sharedPreferences.setString(AppKeys.user, jsonEncode(user.toJson()));
    await sharedPreferences.setString(AppKeys.accessToken, user.accessToken);
    await sharedPreferences.setString(AppKeys.refreshToken, user.refreshToken);
  }

  Future<void> _clearUser() async {
    await sharedPreferences.remove(AppKeys.user);
    await sharedPreferences.remove(AppKeys.accessToken);
    await sharedPreferences.remove(AppKeys.refreshToken);
  }
}
