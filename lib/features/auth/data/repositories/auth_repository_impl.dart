import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/UserModel.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
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
      final refreshToken = sharedPreferences.getString('refresh_token');
      if (refreshToken != null) {
        await dio.post(
          '/auth/logout',
          data: {'refresh_token': refreshToken},
          options: Options(contentType: 'application/json'),
        );
      }
      await _clearUser();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userJson = sharedPreferences.getString('user');
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
      final refreshToken = sharedPreferences.getString('refresh_token');
      if (refreshToken != null) {
        final response = await dio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
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
        '/users/me',
        options: Options(
          contentType: 'application/json',
          headers: {'Authorization': 'Bearer ${sharedPreferences.getString('access_token')}'},
        ),
      );
      final userModel = UserModel.fromJson(response.data['data']);
      await _saveUser(userModel);
      return userModel.toEntity();
    } catch (e) {
      throw Exception('Get profile failed: $e');
    }
  }

  Future<void> _saveUser(UserModel user) async {
    await sharedPreferences.setString('user', jsonEncode(user.toJson()));
    await sharedPreferences.setString('access_token', user.accessToken);
    await sharedPreferences.setString('refresh_token', user.refreshToken);
  }

  Future<void> _clearUser() async {
    await sharedPreferences.remove('user');
    await sharedPreferences.remove('access_token');
    await sharedPreferences.remove('refresh_token');
  }
}