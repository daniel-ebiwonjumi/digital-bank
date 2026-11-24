import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../models/bank_transfer_failure.dart';
import '../models/bank_transfer_models.dart';
import '../services/bank_transfer_service.dart';
import 'bank_transfer_repository.dart';

class BankTransferRepositoryImpl implements BankTransferRepository {
  BankTransferRepositoryImpl(
    this._service, {
    Duration bankCacheDuration = const Duration(hours: 6),
    DateTime Function() now = DateTime.now,
  }) : _bankCacheDuration = bankCacheDuration,
       _now = now;

  final BankTransferService _service;
  final Duration _bankCacheDuration;
  final DateTime Function() _now;

  List<Bank>? _cachedBanks;
  DateTime? _cachedAt;

  @override
  Future<List<Bank>> getBanks() async {
    final cached = _cachedBanks;
    final cachedAt = _cachedAt;
    if (cached != null &&
        cachedAt != null &&
        _now().difference(cachedAt) < _bankCacheDuration) {
      return cached;
    }

    try {
      final banks = await _guard(_service.getBanks);
      final sorted = [...banks]
        ..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      final result = List<Bank>.unmodifiable(sorted);
      _cachedBanks = result;
      _cachedAt = _now();
      return result;
    } on BankTransferFailure {
      // A stale list is better than no list.
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<BankRecipient> resolveRecipient({
    required Bank bank,
    required String accountNumber,
  }) {
    return _guard(() async {
      final recipient = await _service.resolveAccount(
        bank: bank,
        accountNumber: accountNumber,
      );

      // Never show a name for a different account than the one requested.
      if (recipient.accountNumber != accountNumber) {
        throw const FormatException('Recipient does not match the request');
      }
      return recipient;
    });
  }

  @override
  Future<double> getTransferFee(double amountInNaira) {
    return _guard(() => _service.getFee(amountInNaira));
  }

  @override
  Future<BankTransferReceipt> transfer({
    required String idempotencyKey,
    required BankTransferDraft draft,
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
      final matches =
          receipt.recipient.accountNumber == draft.recipient.accountNumber &&
          receipt.recipient.bank.code == draft.recipient.bank.code &&
          _sameAmount(receipt.amountInNaira, draft.amountInNaira) &&
          _sameAmount(receipt.feeInNaira, draft.feeInNaira);
      if (!matches) {
        throw const FormatException('Receipt does not match the request');
      }
      return receipt;
    });
  }

  @override
  Future<BankTransferReceipt> getTransfer(String reference) {
    return _guard(() async {
      final receipt = await _service.getTransfer(reference);
      if (receipt.reference != reference) {
        throw const FormatException('Receipt does not match the request');
      }
      return receipt;
    });
  }

  static bool _sameAmount(double a, double b) => (a - b).abs() < 0.005;

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
        name: 'BankTransferRepository',
        error: error,
        stackTrace: stackTrace,
      );
      throw BankTransferFailure(BankTransferErrorCode.unexpectedResponse);
    }
  }

  BankTransferFailure _toFailure(DioException e) {
    final response = e.response;

    // No response: timeout, no connection, dropped connection, etc.
    if (response == null) {
      if (e.type == DioExceptionType.badCertificate) {
        return BankTransferFailure(
          BankTransferErrorCode.rejected,
          message: 'We could not establish a secure connection.',
        );
      }
      return BankTransferFailure(BankTransferErrorCode.network);
    }

    final data = response.data;
    final serverCode = data is Map && data['code'] is String
        ? data['code'] as String
        : null;
    final byCode = BankTransferErrorCode.fromServerCode(serverCode);
    if (byCode != null) return BankTransferFailure(byCode);

    final status = response.statusCode ?? 0;
    if (status == 401) {
      return BankTransferFailure(BankTransferErrorCode.sessionExpired);
    }
    if (status == 404) {
      return BankTransferFailure(BankTransferErrorCode.recipientNotFound);
    }
    if (status == 429) {
      return BankTransferFailure(BankTransferErrorCode.rateLimited);
    }
    if (status >= 500) {
      return BankTransferFailure(BankTransferErrorCode.server);
    }

    final message = (status == 400 || status == 409 || status == 422)
        ? _serverMessage(data)
        : null;
    return BankTransferFailure(
      BankTransferErrorCode.rejected,
      message: message,
    );
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
