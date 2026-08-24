import 'package:flutter/foundation.dart';

import 'package:digital_bank/data/repositories/user.dart';
import 'package:digital_bank/data/repositories/auth_repository/auth_repostory.dart';

enum AuthStatus {
  loading,
  authenticated,
  unauthenticated,
}

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthViewModel(this.authRepository);

  AuthStatus _status = AuthStatus.loading;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;

  bool get isAuthenticated =>
      _status == AuthStatus.authenticated;

  Future<void> checkAuthentication() async {
    _status = AuthStatus.loading;
    _error = null;

    notifyListeners();

    try {
      _user = await authRepository.getCurrentUser();

      _status = AuthStatus.authenticated;
    } catch (_) {
      await authRepository.logout();

      _user = null;
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login({
    required String mobileNumberOrEmail,
    required String password,
  }) async {
    _error = null;
    notifyListeners();

    try {
      _user = await authRepository.login(
        mobileNumberOrEmail: mobileNumberOrEmail,
        password: password,
      );

      _status = AuthStatus.authenticated;

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return false;
    }
  }

  Future<bool> register({
    required String mobileNumber,
    required String password,
   
  }) async {
    _error = null;
    notifyListeners();

    try {
      _user = await authRepository.register(
        mobileNumber: mobileNumber,
        password: password,
  
      );

      _status = AuthStatus.authenticated;

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();

    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;

    notifyListeners();
  }
}