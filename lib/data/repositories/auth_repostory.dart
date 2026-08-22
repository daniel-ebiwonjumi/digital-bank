import 'package:dio/dio.dart';
import 'user.dart';
import '../services/auth_services/auth_service.dart';
import '../services/auth_services/auth_token_storage.dart';

class AuthRepository {
  final AuthService auth;
  final AuthTokenStorage tokenStorage;

  AuthRepository({
    required this.auth,
    required this.tokenStorage,
  });

  Future<User> login({required String mobileNumberOrEmail, required String password}) async {
    try {
      final response = await auth.login(mobileNumberOrEmail, password);
      final data = response.data;

      await tokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      return User.fromJson(data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> register({required String mobileNumber, required String password}) async {
    try {
      final response = await auth.register(mobileNumber, password);
      final data = response.data;

      await tokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );

      return User.fromJson(data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await auth.getCurrentUser();
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await auth.logout(refreshToken);
      }
    } catch (_) {
      // Fail silently for server logout to ensure local data wipes
    } finally {
      await tokenStorage.clearTokens();
    }
  }

  Future<void> refreshAccessToken() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token');

      final response = await auth.refreshAccessToken(refreshToken);
      await tokenStorage.saveAccessToken(response.data['accessToken']);
    } on DioException catch (e) {
      await tokenStorage.clearTokens();
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
        case 401: return 'Invalid email or password.';
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
