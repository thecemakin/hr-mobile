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
  final String role;
  final int? employeeId;
  final bool isAuthenticated;

  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.email,
    this.role = 'employee',
    this.employeeId,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? email,
    String? role,
    int? employeeId,
    bool? isAuthenticated,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isHR => role.toLowerCase() == 'hr';
  bool get isManager => role.toLowerCase() == 'manager';
  bool get isEmployee => role.toLowerCase() == 'employee';

  List<String> get roles => [role];
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

      final token = response['token'] as String?;
      final user = response['user'] as Map<String, dynamic>?;
      final role = (user?['role'] as String?)?.toLowerCase() ?? 'employee';
      final userId = user?['id']?.toString();
      final userEmail = user?['email'] as String?;
      final employeeId = user?['employee_id'] != null
          ? int.tryParse(user!['employee_id'].toString())
          : null;

      if (token != null) {
        await _storage.write(key: AppConstants.accessTokenKey, value: token);
      }
      if (userId != null) {
        await _storage.write(key: AppConstants.userIdKey, value: userId);
      }
      if (userEmail != null) {
        await _storage.write(key: AppConstants.userEmailKey, value: userEmail);
      }
      await _storage.write(key: AppConstants.userRoleKey, value: role);
      if (employeeId != null) {
        await _storage.write(
          key: AppConstants.userEmployeeIdKey,
          value: employeeId.toString(),
        );
      }

      state = AuthState(
        accessToken: token,
        userId: userId,
        email: userEmail,
        role: role,
        employeeId: employeeId,
        isAuthenticated: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.userIdKey);
    await _storage.delete(key: AppConstants.userEmailKey);
    await _storage.delete(key: AppConstants.userRoleKey);
    await _storage.delete(key: AppConstants.userEmployeeIdKey);
    state = const AuthState();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final userId = await _storage.read(key: AppConstants.userIdKey);
    final email = await _storage.read(key: AppConstants.userEmailKey);
    final role = await _storage.read(key: AppConstants.userRoleKey);
    final employeeIdStr = await _storage.read(
      key: AppConstants.userEmployeeIdKey,
    );

    if (token != null) {
      state = AuthState(
        accessToken: token,
        userId: userId,
        email: email,
        role: role?.toLowerCase() ?? 'employee',
        employeeId: employeeIdStr != null ? int.tryParse(employeeIdStr) : null,
        isAuthenticated: true,
      );
    }
  }
}
