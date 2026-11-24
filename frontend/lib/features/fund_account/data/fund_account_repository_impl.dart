limport 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../models/funding_models.dart';
import '../services/fund_account_service.dart';
import 'fund_account_repository.dart';

class FundAccountRepositoryImpl implements FundAccountRepository {
  const FundAccountRepositoryImpl(this._service);

  final FundAccountService _service;

  @override
  Future<FundingSession> initializeFunding({
    required double amountInNaira,
    required FundingMethod method,
  }) {
    return _guard(
      () => _service.initialize(amountInNaira: amountInNaira, method: method),
    );
  }

  @override
  Future<FundingStatus> verifyFunding(String reference) {
    return _guard(() => _service.verify(reference));
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _toFailure(e);
    } catch (error, stackTrace) {
      // Malformed JSON, missing fields, etc. Logged so bugs are not hidden.
      developer.log(
        'Unexpected error',
        name: 'FundAccountRepository',
        error: error,
        stackTrace: stackTrace,
      );
      throw const Failure(
        'Unexpected response from the server. Please try again.',
      );
    }
  }

  static const _networkErrors = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  };

  Failure _toFailure(DioException e) {
    if (_networkErrors.contains(e.type)) {
      return const Failure(
        'Network problem. Check your connection and try again.',
      );
    }
    if (e.type == DioExceptionType.badCertificate) {
      return const Failure('We could not establish a secure connection.');
    }
    if (e.type == DioExceptionType.cancel) {
      return const Failure('The request was cancelled.');
    }

    final status = e.response?.statusCode;
    if (status == 401) {
      return const Failure('Your session has expired. Please log in again.');
    }
    if (status == 429) {
      return const Failure(
        'Too many attempts. Please wait a moment and try again.',
      );
    }
    if (status != null && status >= 500) {
      return const Failure(
        'Our servers are having a problem. Please try again shortly.',
      );
    }

    // Only show server messages for errors meant for the user (validation,
    // conflicts). Anything else gets a generic message.
    if (status == 400 || status == 409 || status == 422) {
      final message = _serverMessage(e.response?.data);
      if (message != null) return Failure(message);
    }

    return const Failure('Something went wrong. Please try again.');
  }

  /// NestJS errors look like { statusCode, message } where message is either
  /// a string or a list of validation errors.
  String? _serverMessage(Object? data) {
    if (data is! Map) return null;

    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) return message;
    if (message is List) {
      final joined = message.whereType<String>().join('\n');
      return joined.isEmpty ? null : joined;
    }
    return null;
  }
}