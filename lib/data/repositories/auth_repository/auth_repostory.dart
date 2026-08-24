import 'package:dio/dio.dart';
import 'package:digital_bank/data/repositories/user.dart';
import 'package:digital_bank/data/services/auth_services/auth_service.dart';
import 'package:digital_bank/data/services/auth_services/auth_token_storage.dart';

class AuthRepository {
  final AuthService authService;
  final AuthTokenStorage authTokenStorage;

  const AuthRepository({
    required this.authService,
    required this.authTokenStorage,
  });

  Future<User> login({required String mobileNumberOrEmail, required String password}) async {
    try {
      final response = await authService.login(mobileNumberOrEmail, password);
      final data = response.data;

      await authTokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      return User.fromMap(data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> register({required String mobileNumber, required String password}) async {
    try {
      final response = await authService.register(mobileNumber, password);
      final data = response.data;

      await authTokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      return User.fromMap(data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await authService.getCurrentUser();
      return User.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await authTokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await authService.logout(refreshToken);
      }
    } catch (_) {
      
    } finally {
      await authTokenStorage.clearTokens();
    }
  }

  Future<void> refresh() async {
    try {
      final refreshToken = await authTokenStorage.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token');

      final response = await authService.refresh(refreshToken);
      await authTokenStorage.saveAccessToken(response.data['accessToken']);
    } on DioException catch (e) {
      await authTokenStorage.clearTokens();
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] is String) return data['message'];
        if (data['message'] is List) return (data['message'] as List).join(', ');
      }
      switch (e.response?.statusCode) {
        case 400: return 'Invalid request.';
        case 401: return 'Invalid email or mobile number or password.';
        case 403: return 'You are not allowed to perform this action.';
        case 404: return 'Resource not found.';
        case 429: return 'Too many attempts. Please try again later.';
        case 500: return 'Server error. Please try again later.';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server.';
    }
    return 'Something went wrong.';
  }
}
