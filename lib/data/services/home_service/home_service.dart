import 'package:digital_bank/data/services/api_config.dart';
import 'package:dio/dio.dart';

class HomeService {
late final DioConfig dioConfig;
  Future<Response> getHomeData() async {
    return await dioConfig.dio.get(ApiConfig.home);
  }
}