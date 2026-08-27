import 'package:dio/dio.dart';
import '../api_config.dart';
import 'auth_token_storage.dart';

class AuthService {
  final Api api;
  AuthService(this.api);

  Future<Response> login(String mobileNumberOrEmail, String password) async {
    return await api.dio.post(
      ApiConfig.login,
      data: {'mobileNumberOrEmail': mobileNumberOrEmail, 'password': password},
    );
  }

  Future<Response> register(String mobileNumber, String password) async {
    return await api.dio.post(
      ApiConfig.register,
      data: {'mobileNumber': mobileNumber, 'password': password},
    );
  }

  Future<Response> getCurrentUser() async {
    return await api.dio.post(ApiConfig.me);
  }

  Future<Response> logout(String refreshToken) async {
    return await api.dio.post(ApiConfig.logout, data: {'refreshToken': refreshToken});
  }

  Future<Response> refresh(String refreshToken) async {
    return await api.dio.post(
      ApiConfig.refresh,
      data: {'refreshToken': refreshToken},
    );
  }
}

class Api {
  final AuthTokenStorage authTokenStorage;
  late final Dio dio;

  Api(this.authTokenStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl, //TODO: put the proper url here later
        connectTimeout: Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await authTokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }
}
