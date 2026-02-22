import 'package:arsys/features/auth/data/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthTokenNotifier extends Notifier<String?> {
  @override
  String? build() {
    return ref.read(authServiceProvider).token;
  }

  void setToken(String? token) => state = token;
}

final authTokenProvider = NotifierProvider<AuthTokenNotifier, String?>(AuthTokenNotifier.new);

final userRoleProvider = Provider<String?>((ref) {
  ref.watch(authTokenProvider);
  final roles = ref.read(authServiceProvider).roles;
  if (roles != null && roles.isNotEmpty) {
    return roles.first;
  }
  return null;
});

final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.user;
});

enum AuthState {
  authenticated,
  unauthenticated,
}

final authStateProvider = Provider<AuthState>((ref) {
  final token = ref.watch(authTokenProvider);
  if (token != null) {
    return AuthState.authenticated;
  }
  return AuthState.unauthenticated;
});
