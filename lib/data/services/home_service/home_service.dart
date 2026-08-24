import 'package:digital_bank/data/services/api_config.dart';
import 'package:dio/dio.dart';

class HomeService {
  Future<Response> getHomeData() async {
    return await dio.get(ApiConfig.home);
  }
}

Dio dio = Dio(
  BaseOptions(
    baseUrl: '', //TODO: put the proper url here later
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ),
);
