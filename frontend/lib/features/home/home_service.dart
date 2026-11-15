import 'package:digital_bank/core/api_config.dart';
import 'package:digital_bank/core/dio_config.dart';
import 'package:dio/dio.dart';

class HomeService {
  final DioConfig dioConfig;
  const HomeService(this.dioConfig);

  Future<Response> getHomeData () async {
    return await dioConfig.dio.get(ApiConfig.home);
  }
}