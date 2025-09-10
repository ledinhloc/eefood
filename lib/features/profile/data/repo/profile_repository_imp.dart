import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/auth/data/models/result_model.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/profile/domain/repositories/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_keys.dart';

class ProfileRepositoryImpl extends ProfileRepository{
  final Dio dio;
  final SharedPreferences sharedPreferences;
  ProfileRepositoryImpl({required this.dio, required this.sharedPreferences});
  @override
  Future<Result<User>> updateUser(UserModel request) async {
    print(request.toJson());
    try
    {
      final response = await dio.put(
        '/v1/users/update',
        data: request.toJson(),
        options: Options(contentType: 'application/json'),
      );
      final userModelRes = UserModel.fromJson(response.data['data']);
      _saveUser(userModelRes);
      return Result.success(userModelRes.toEntity());
    } catch (e) {
      print(e);
      throw Exception('Save failed: $e');
    }
  }

  Future<void> _saveUser(UserModel userModel) async {
    await sharedPreferences.setString(AppKeys.user, jsonEncode(userModel.toJson()));
  }
}