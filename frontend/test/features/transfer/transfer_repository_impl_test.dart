import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:your_app/features/transfer/data/models/transfer_failure.dart';
import 'package:your_app/features/transfer/data/models/transfer_models.dart';
import 'package:your_app/features/transfer/data/repositories/transfer_repository_impl.dart';
import 'package:your_app/features/transfer/data/services/transfer_service.dart';

class _MockTransferService extends Mock implements TransferService {}

const _recipient = Recipient(
  accountNumber: '0123456789',
  accountName: 'Ada Obi',
);

const _draft = TransferDraft(
  recipient: _recipient,
  amountInNaira: 5000,
  narration: '',
);

TransferReceipt _receipt({
  Recipient recipient = _recipient,
  double amount = 5000,
}) {
  return TransferReceipt(
    reference: 'REF-1',
    amountInNaira: amount,
    recipient: recipient,
    narration: '',
    createdAt: DateTime(2026, 11, 24, 15, 42),
  );
}

DioException _dioError(
  DioExceptionType type, {
  int? statusCode,
  Object? data,
}) {
  final request = RequestOptions(path: '/transfers');
  return DioException(
    requestOptions: request,
    type: type,
    response: statusCode == null
        ? null
        : Response<Object?>(
            requestOptions: request,
            statusCode: statusCode,
            data: data,
          ),
  );
}

Matcher _throwsTransferFailure(
  TransferErrorCode code, {
  required bool outcomeUnknown,
}) {
  return throwsA(
    isA<TransferFailure>()
        .having((f) => f.code, 'code', code)
        .having((f) => f.isOutcomeUnknown, 'isOutcomeUnknown', outcomeUnknown),
  );
}

void main() {
  late _MockTransferService service;
  late TransferRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(_draft));

  setUp(() {
    service = _MockTransferService();
    repository = TransferRepositoryImpl(service);
  });

  When<Future<TransferReceipt>> stubTransfer() {
    return when(
      () => service.transfer(
        idempotencyKey: any(named: 'idempotencyKey'),
        draft: any(named: 'draft'),
        pin: any(named: 'pin'),
      ),
    );
  }

  Future<TransferReceipt> transfer() {
    return repository.transfer(
      idempotencyKey: 'key-1',
      draft: _draft,
      pin: '1234',
    );
  }

  group('resolveRecipient', () {
    test('returns the recipient', () async {
      when(
        () => service.resolveRecipient('0123456789'),
      ).thenAnswer((_) async => _recipient);

      expect(await repository.resolveRecipient('0123456789'), _recipient);
    });

    test('rejects a response for a different account', () async {
      when(() => service.resolveRecipient('0123456789')).thenAnswer(
        (_) async => const Recipient(
          accountNumber: '0987654321',
          accountName: 'Someone Else',
        ),
      );

      await expectLater(
        repository.resolveRecipient('0123456789'),
        _throwsTransferFailure(
          TransferErrorCode.unexpectedResponse,
          outcomeUnknown: true,
        ),
      );
    });

    test('maps 404 to recipientNotFound', () async {
      when(() => service.resolveRecipient(any())).thenThrow(
        _dioError(DioExceptionType.badResponse, statusCode: 404),
      );

      await expectLater(
        repository.resolveRecipient('0123456789'),
        _throwsTransferFailure(
          TransferErrorCode.recipientNotFound,
          outcomeUnknown: false,
        ),
      );
    });
  });

  group('transfer', () {
    test('returns the receipt and sends the idempotency key', () async {
      stubTransfer().thenAnswer((_) async => _receipt());

      final receipt = await transfer();

      expect(receipt.reference, 'REF-1');
      verify(
        () => service.transfer(
          idempotencyKey: 'key-1',
          draft: _draft,
          pin: '1234',
        ),
      ).called(1);
    });

    test('maps the server code INSUFFICIENT_FUNDS', () async {
      stubTransfer().thenThrow(
        _dioError(
          DioExceptionType.badResponse,
          statusCode: 422,
          data: {'statusCode': 422, 'code': 'INSUFFICIENT_FUNDS'},
        ),
      );

      await expectLater(
        transfer(),
        _throwsTransferFailure(
          TransferErrorCode.insufficientFunds,
          outcomeUnknown: false,
        ),
      );
    });

    test('maps INVALID_PIN', () async {
      stubTransfer().thenThrow(
        _dioError(
          DioExceptionType.badResponse,
          statusCode: 403,
          data: {'code': 'INVALID_PIN'},
        ),
      );

      await expectLater(
        transfer(),
        _throwsTransferFailure(
          TransferErrorCode.invalidPin,
          outcomeUnknown: false,
        ),
      );
    });

    test('treats a timeout as an unknown outcome', () async {
      stubTransfer().thenThrow(_dioError(DioExceptionType.receiveTimeout));

      await expectLater(
        transfer(),
        _throwsTransferFailure(
          TransferErrorCode.network,
          outcomeUnknown: true,
        ),
      );
    });

    test('treats a 500 as an unknown outcome and hides its details', () async {
      stubTransfer().thenThrow(
        _dioError(
          DioExceptionType.badResponse,
          statusCode: 500,
          data: {'message': 'QueryFailedError: relation does not exist'},
        ),
      );

      await expectLater(
        transfer(),
        throwsA(
          isA<TransferFailure>()
              .having((f) => f.code, 'code', TransferErrorCode.server)
              .having((f) => f.message, 'message', isNot(contains('Query'))),
        ),
      );
    });

    test(
      'treats an unreadable success response as an unknown outcome',
      () async {
        stubTransfer().thenThrow(const FormatException('bad json'));

        await expectLater(
          transfer(),
          _throwsTransferFailure(
            TransferErrorCode.unexpectedResponse,
            outcomeUnknown: true,
          ),
        );
      },
    );

    test(
      'treats a receipt for a different amount as an unknown outcome',
      () async {
        stubTransfer().thenAnswer((_) async => _receipt(amount: 50));

        await expectLater(
          transfer(),
          _throwsTransferFailure(
            TransferErrorCode.unexpectedResponse,
            outcomeUnknown: true,
          ),
        );
      },
    );

    test('asks the user to log in again on 401', () async {
      stubTransfer().thenThrow(
        _dioError(DioExceptionType.badResponse, statusCode: 401),
      );

      await expectLater(
        transfer(),
        _throwsTransferFailure(
          TransferErrorCode.sessionExpired,
          outcomeUnknown: false,
        ),
      );
    });
  });
}
