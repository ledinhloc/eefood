import 'package:dio/dio.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../di/injection.dart';

/* Setting Dio */
/* handler refresh token */
class DioClient {
  final Dio dio = Dio();

  DioClient() {
    final baseUrl = const String.fromEnvironment('BASE_URL', defaultValue: 'http://192.168.1.20:8222/api');
    print(baseUrl);
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5), // Timeout kết nối
      receiveTimeout: const Duration(seconds: 3), // Timeout nhận dữ liệu
      contentType: 'application/json; charset=UTF-8', // Default content type
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