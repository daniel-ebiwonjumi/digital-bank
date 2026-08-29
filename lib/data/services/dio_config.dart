import 'package:digital_bank/data/services/api_config.dart';
import 'package:digital_bank/data/services/auth_services/auth_token_storage.dart';
import 'package:dio/dio.dart';

class DioConfig {
  late final Dio dio;
  late final AuthTokenStorage authTokenStorage;

  DioConfig() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
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
          final publicEndpoints = [
            ApiConfig.login,
            ApiConfig.register,
            ApiConfig.refresh,
          ];
          if(!publicEndpoints.contains(options.path)){ 
          final token = await authTokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        }
        }
      ),
    );
  }
}
