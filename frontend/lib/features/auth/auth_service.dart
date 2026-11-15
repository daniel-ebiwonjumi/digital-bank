import 'package:digital_bank/core/api_config.dart';
import 'package:digital_bank/core/dio_config.dart';
import 'package:dio/dio.dart';


class AuthService {
  final DioConfig dioConfig;
  AuthService(this.dioConfig);

  Future<Response> login(String mobileNumberOrEmail, String password) async {
    return await dioConfig.dio.post(
      ApiConfig.login,
      data: {'mobileNumberOrEmail': mobileNumberOrEmail, 'password': password},
    );
  }

  Future<Response> register(String mobileNumber, String password) async {
    return await dioConfig.dio.post(
      ApiConfig.register,
      data: {'mobileNumber': mobileNumber, 'password': password},
    );
  }

  Future<Response> getCurrentUser() async {
    return await dioConfig.dio.get(ApiConfig.me);
  }

  Future<Response> logout(String refreshToken) async {
    return await dioConfig.dio.post(
      ApiConfig.logout,
      data: {'refreshToken': refreshToken},
    );
  }

  Future<Response> refresh(String refreshToken) async {
    return await dioConfig.dio.post(
      ApiConfig.refresh,
      data: {'refreshToken': refreshToken},
    );
  }
}
