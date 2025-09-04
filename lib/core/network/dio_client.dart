import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../di/injection.dart';

/* Setting Dio */
/* handler refresh token */
class DioClient {
  final Dio dio = Dio();

  DioClient() {
    final baseUrl = const String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8222/api');
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
        // Lấy access token từ SharedPreferences
        final prefs = getIt<SharedPreferences>();
        final accessToken = prefs.getString('access_token');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Xử lý lỗi 401 (Unauthorized) bằng cách refresh token
        if (e.response?.statusCode == 401) {
          try {
            final refreshToken = getIt<SharedPreferences>().getString('refresh_token');
            if (refreshToken != null) {
              await getIt<RefreshToken>()(); // Gọi use case refresh token
              final newAccessToken = getIt<SharedPreferences>().getString('access_token');
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
          } catch (e) {
            // return handler.next(e); // Nếu refresh token thất bại, tiếp tục lỗi
          }
        }
        return handler.next(e); // Tiếp tục lỗi nếu không phải 401
      },
    ));
  }
}