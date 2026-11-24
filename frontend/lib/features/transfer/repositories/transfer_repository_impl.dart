import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../models/transfer_failure.dart';
import '../models/transfer_models.dart';
import '../services/transfer_service.dart';
import 'transfer_repository.dart';

class TransferRepositoryImpl implements TransferRepository {
  const TransferRepositoryImpl(this._service);

  final TransferService _service;

  @override
  Future<Recipient> resolveRecipient(String accountNumber) {
    return _guard(() async {
      final recipient = await _service.resolveRecipient(accountNumber);

      // Never show a name for a different account than the one requested.
      if (recipient.accountNumber != accountNumber) {
        throw const FormatException('Recipient does not match the request');
      }
      return recipient;
    });
  }

  @override
  Future<TransferReceipt> transfer({
    required String idempotencyKey,
    required TransferDraft draft,
    required String pin,
  }) {
    return _guard(() async {
      final receipt = await _service.transfer(
        idempotencyKey: idempotencyKey,
        draft: draft,
        pin: pin,
      );

      // The receipt must describe what the user confirmed. If it does not,
      // we cannot trust the outcome, so it is reported as unknown.
      final sameRecipient =
          receipt.recipient.accountNumber == draft.recipient.accountNumber;
      final sameAmount =
          (receipt.amountInNaira - draft.amountInNaira).abs() < 0.005;
      if (!sameRecipient || !sameAmount) {
        throw const FormatException('Receipt does not match the request');
      }
      return receipt;
    });
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _toFailure(e);
    } catch (error, stackTrace) {
      // Malformed JSON, mismatched receipt, etc. Never log the request: it
      // contains the PIN.
      developer.log(
        'Unexpected error',
        name: 'TransferRepository',
        error: error,
        stackTrace: stackTrace,
      );
      throw TransferFailure(TransferErrorCode.unexpectedResponse);
    }
  }

  TransferFailure _toFailure(DioException e) {
    final response = e.response;

    // No response: timeout, no connection, dropped connection, etc.
    if (response == null) {
      if (e.type == DioExceptionType.badCertificate) {
        return TransferFailure(
          TransferErrorCode.rejected,
          message: 'We could not establish a secure connection.',
        );
      }
      return TransferFailure(TransferErrorCode.network);
    }

    final data = response.data;
    final serverCode = data is Map && data['code'] is String
        ? data['code'] as String
        : null;
    final byCode = TransferErrorCode.fromServerCode(serverCode);
    if (byCode != null) return TransferFailure(byCode);

    final status = response.statusCode ?? 0;
    if (status == 401) return TransferFailure(TransferErrorCode.sessionExpired);
    if (status == 404) {
      return TransferFailure(TransferErrorCode.recipientNotFound);
    }
    if (status == 429) return TransferFailure(TransferErrorCode.rateLimited);
    if (status >= 500) return TransferFailure(TransferErrorCode.server);

    final message = (status == 400 || status == 409 || status == 422)
        ? _serverMessage(data)
        : null;
    return TransferFailure(TransferErrorCode.rejected, message: message);
  }

  /// NestJS validation errors: { statusCode, message } where message is a
  /// string or a list of strings.
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
