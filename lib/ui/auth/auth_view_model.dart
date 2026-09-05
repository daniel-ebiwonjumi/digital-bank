import 'package:signals/signals_flutter.dart';

import 'package:digital_bank/data/repositories/user.dart';
import 'package:digital_bank/data/repositories/auth_repository/auth_repostory.dart';

enum AuthStatus {
  loading,
  authenticated,
  unauthenticated,
}

class AuthViewModel {
  final AuthRepository authRepository;

  AuthViewModel(this.authRepository);

final isLoading = signal<bool>(true);
final isObscureLoginPassword = signal<bool>(true);
final isObscureRegisterPassword = signal<bool>(true);
  final status = signal<AuthStatus>(AuthStatus.loading);
  final user = signal<User?>(null);
  final error = signal<String?>(null);


  Future<void> checkAuthentication() async {
    status.value = AuthStatus.loading;
    error.value = null;

    try {
      user.value = await authRepository.getCurrentUser();

      status.value = AuthStatus.authenticated;
    } catch (_) {
      await authRepository.logout();

      user.value = null;
      status.value = AuthStatus.unauthenticated;
    }
  }

  Future<bool> login({
    required String mobileNumberOrEmail,
    required String password,
  }) async {
    error.value = null;

    try {
      user.value = await authRepository.login(
        mobileNumberOrEmail: mobileNumberOrEmail,
        password: password,
      );

      status.value = AuthStatus.authenticated;

      return true;
    } catch (e) {
      error.value = e.toString();
      status.value = AuthStatus.unauthenticated;

      return false;
    }
  }

  Future<bool> register({
    required String mobileNumber,
    required String password,
  }) async {
    error.value = null;

    try {
      user.value = await authRepository.register(
        mobileNumber: mobileNumber,
        password: password,
      );

      status.value = AuthStatus.authenticated;

      return true;
    } catch (e) {
      error.value = e.toString();
      status.value = AuthStatus.unauthenticated;

      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();

    user.value = null;
    status.value = AuthStatus.unauthenticated;
    error.value = null;
  }

  void dispose() {
isObscureLoginPassoword.dispose();
isObscureRegisterPassword.dispose();
    status.dispose();
    user.dispose();
    error.dispose();
  
  }
}