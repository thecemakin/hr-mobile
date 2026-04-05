import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  AuthInterceptor({required this.storage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await storage.read(
        key: AppConstants.refreshTokenKey,
      );
      if (refreshToken != null) {
        try {
          final dio = Dio(
            BaseOptions(
              baseUrl: AppConstants.baseUrl,
              connectTimeout: const Duration(
                milliseconds: AppConstants.connectionTimeout,
              ),
              receiveTimeout: const Duration(
                milliseconds: AppConstants.receiveTimeout,
              ),
            ),
          );

          final response = await dio.post(
            '${AppConstants.apiV1}/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];

            await storage.write(
              key: AppConstants.accessTokenKey,
              value: newAccessToken,
            );
            if (newRefreshToken != null) {
              await storage.write(
                key: AppConstants.refreshTokenKey,
                value: newRefreshToken,
              );
            }

            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            final clonedResponse = await dio.fetch(opts);
            return handler.resolve(clonedResponse);
          }
        } catch (_) {
          await storage.delete(key: AppConstants.accessTokenKey);
          await storage.delete(key: AppConstants.refreshTokenKey);
        }
      }
    }
    handler.next(err);
  }
}
