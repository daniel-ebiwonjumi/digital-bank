import 'package:digital_bank/data/services/api_config.dart';
import 'package:dio/dio.dart';
import 'package:digital_bank/data/services/dio_config.dart';

class HomeService {
  final DioConfig dioConfig;
  const HomeService(this.dioConfig);

  Future<Response> getHome () async {
    return await dioConfig.dio.get(ApiConfig.home);
  }
}