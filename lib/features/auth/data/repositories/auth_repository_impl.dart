import 'package:dio/dio.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/features/auth/data/models/otp_model.dart';
import 'package:eefood/features/auth/data/models/response_data_model.dart';
import 'package:eefood/features/auth/domain/entities/otp.dart';
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
                'Bearer ${sharedPreferences.getString('access_token')}',
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
  Future<ResponseDataModel<User>> register(String username, String email, String password) async {
    try {
      final response = await dio.post(
        '/v1/auth/register',
        data: {'username': username, 'email': email, 'password': password},
        options: Options(contentType: 'application/json'),
      );
      final userModel = UserModel.fromJson(response.data['data']);
      final resp = ResponseDataModel.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as UserModel, 
      );
      return ResponseDataModel<User>(
        status: resp.status,
        message: resp.message,
        data: userModel.toEntity(),
      );
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }

  @override
  Future<ResponseDataModel<bool>> verifyOtp(String email, String otpCode, OtpType otpType) async {
    try {
      final response = await dio.post(
        '/v1/auth/verify-otp',
        data: {'email': email, 'otpCode': otpCode, 'otpType': otpType.name},
        options: Options(contentType: 'application/json'),
      );
      final resp = ResponseDataModel.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as bool, 
      );
      return ResponseDataModel<bool>(
        status: resp.status,
        message: resp.message,
        data: resp.status == 200,
      );
    } catch (e) {
      throw Exception('Verify otp failed: $e');
    }
  }

  @override
  Future<ResponseDataModel<bool>> forgotPassword(String email) async {
    try {
      final response = await dio.post(
        '/v1/auth/forgot-password/request',
        data: {'email': email},
        options: Options(contentType: 'application/json'),
      );

      final resp = ResponseDataModel.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as bool, 
      );
      return ResponseDataModel<bool>(
        status: resp.status,
        message: resp.message,
        data: resp.status == 200,
      );
    } catch (e) {
      throw Exception('Forgot password failed: $e');
    }
  }

  @override
  Future<ResponseDataModel<bool>> resetPassword(String email, String otpCode, String newPassword) async {
    try {
      final response = await dio.post(
        '/v1/auth/forgot-password/reset',
        data: {'email': email, 'otp': otpCode, 'newPassword': newPassword},
        options: Options(contentType: 'application/json'),
      );

      final resp = ResponseDataModel.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as bool, 
      );
      return ResponseDataModel<bool>(
        status: resp.status,
        message: resp.message,
        data: resp.status == 200,
      );
      
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
