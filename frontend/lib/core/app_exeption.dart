class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() {
    return message;
  }
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'Unable to connect to the server'});
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Your session has expired'});
}
