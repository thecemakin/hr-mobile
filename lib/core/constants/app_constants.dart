class AppConstants {
  AppConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String apiV1 = '/api/v1';
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 15000;

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
