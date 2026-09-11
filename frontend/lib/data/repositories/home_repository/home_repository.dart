import 'package:digital_bank/data/repositories/app_exeption.dart';
import 'package:digital_bank/data/repositories/home_repository/home_data.dart';
import 'package:digital_bank/data/services/home_service/home_service.dart';
import 'package:dio/dio.dart';

class HomeRepository {
  final HomeService homeService;

  const HomeRepository(this.homeService);

  Future<HomeData> getHomeData() async {
    try {
      final response = await homeService.getHomeData();
      final _data = response.data;

      return HomeData.fromMap(_data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _handleDioException(error);
    } on FormatException {
      throw const AppException(message: 'The server returned invalid data');
    }
  }

  AppException _handleDioException(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return const UnauthorizedException();
    }
    return ServerException(
      message: _extractMessage(error),
      statusCode: statusCode,
    );
  }

  String _extractMessage(DioException error) {
    final _data = error.response?.data;

    if (_data is Map<String, dynamic>) {
      final message = _data['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
    }
    return 'Something went wrong, please try again';
  }
}
