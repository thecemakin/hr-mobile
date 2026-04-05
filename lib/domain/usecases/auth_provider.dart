import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/api/dio_client.dart';
import '../../data/api/auth_service.dart';
import '../../core/constants/app_constants.dart';

class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? email;
  final List<String> roles;
  final bool isAuthenticated;

  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.email,
    this.roles = const [],
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? email,
    List<String>? roles,
    bool? isAuthenticated,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

final storageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(storage: ref.watch(storageProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(dio: ref.watch(dioClientProvider).dio);
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService = ref.watch(authServiceProvider);
  late final FlutterSecureStorage _storage = ref.watch(storageProvider);

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      final accessToken = response['accessToken'] as String?;
      final refreshToken = response['refreshToken'] as String?;
      final user = response['user'] as Map<String, dynamic>?;

      if (accessToken != null) {
        await _storage.write(
          key: AppConstants.accessTokenKey,
          value: accessToken,
        );
      }
      if (refreshToken != null) {
        await _storage.write(
          key: AppConstants.refreshTokenKey,
          value: refreshToken,
        );
      }

      state = state.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: user?['id']?.toString(),
        email: user?['email']?.toString(),
        roles: _parseRoles(user?['roles']),
        isAuthenticated: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  List<String> _parseRoles(dynamic roles) {
    if (roles == null) return [];
    if (roles is List) {
      return roles.map((e) => e.toString()).toList();
    }
    if (roles is String) {
      return roles
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    state = const AuthState();
  }

  Future<void> checkAuthStatus() async {
    final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);

    if (accessToken != null) {
      state = state.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        isAuthenticated: true,
      );
    }
  }
}
