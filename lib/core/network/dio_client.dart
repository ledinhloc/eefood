import 'dart:math';

import 'package:dio/dio.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/widgets/loading_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../main.dart';
import '../di/injection.dart';
import '../widgets/snack_bar.dart';

/* Setting Dio */
/* handler refresh token */
class DioClient {
  final Dio dio = Dio();

  DioClient() {
    final baseUrl = const String.fromEnvironment('BASE_URL', defaultValue: 'http://192.168.1.16:8222/api');
    print(baseUrl);
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5), // Timeout kết nối
      receiveTimeout: const Duration(seconds: 3), // Timeout nhận dữ liệu
      contentType: 'application/json; charset=UTF-8', // Default content type
    );

    // Xử lý loading khi fetch api và lỗi sẽ direct error page
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final context = navigatorKey.currentContext;
          if (context != null) {
            LoadingOverlay().show();
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          LoadingOverlay().hide();
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          LoadingOverlay().hide();

          final context = navigatorKey.currentContext;
          if (context != null && e.type != DioExceptionType.cancel) {
            navigatorKey.currentState?.pushNamed(AppRoutes.errorPage);
          }

          return handler.next(e);
        },
      ),
    );

    // Thêm interceptor để xử lý token và refresh token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        //neu khong requireAuth
        final requireAuth = options.extra['requireAuth'] ?? true;
        if(!requireAuth) return handler.next(options);
        // Lấy access token từ SharedPreferences
        final prefs = getIt<SharedPreferences>();
        final accessToken = prefs.getString(AppKeys.accessToken);
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        final context = navigatorKey.currentContext;
        if(e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown){
          print('Khong co ket noi');
          if (context != null) {
            showCustomSnackBar(context, "Không có kết nối mạng, vui lòng thử lại", isError: true);
          }
          return handler.next(e);
        }

        // Xử lý lỗi 401 (Unauthorized) bằng cách refresh token
        if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('/auth/refresh')) {
          try {
            final refreshToken = getIt<SharedPreferences>().getString(AppKeys.refreshToken);
            if (refreshToken != null) {

              // Gọi use case refresh token
              await getIt<RefreshToken>()();
              final newAccessToken = getIt<SharedPreferences>().getString(AppKeys.accessToken);
              // Tạo lại request với token mới
              final clonedRequest = await dio.request(
                e.requestOptions.path,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers..['Authorization'] = 'Bearer $newAccessToken',
                ),
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );
              return handler.resolve(clonedRequest);
            }
          } catch (err) {
            if (context != null) {
              showCustomSnackBar(context, "Hết phiên đăng nhập, vui lòng đăng nhập lại", isError: true);
            }

            await getIt<Logout>()();

            // Điều hướng về màn welcome
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              AppRoutes.welcome,
                  (route) => true,
            );

            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: 'Refresh token failed',
                type: DioExceptionType.badResponse,
                response: e.response,
              ),
            );
          }
        }
        return handler.next(e); // Tiếp tục lỗi nếu không phải 401
      },
    ));
  }
}