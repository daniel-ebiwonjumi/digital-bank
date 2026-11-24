import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:your_app/features/bank_transfer/data/models/bank_transfer_failure.dart';
import 'package:your_app/features/bank_transfer/data/models/bank_transfer_models.dart';
import 'package:your_app/features/bank_transfer/data/repositories/bank_transfer_repository_impl.dart';
import 'package:your_app/features/bank_transfer/data/services/bank_transfer_service.dart';

class _MockBankTransferService extends Mock implements BankTransferService {}

const _access = Bank(code: '044', name: 'Access Bank');
const _zenith = Bank(code: '057', name: 'Zenith Bank');

const _recipient = BankRecipient(
  bank: _access,
  accountNumber: '0123456789',
  accountName: 'Ada Obi',
);

const _draft = BankTransferDraft(
  recipient: _recipient,
  amountInNaira: 5000,
  feeInNaira: 26.88,
  narration: '',
);

BankTransferReceipt _receipt({
  String reference = 'REF-1',
  double fee = 26.88,
}) {
  return BankTransferReceipt(
    reference: reference,
    status: BankTransferStatus.pending,
    amountInNaira: 5000,
    feeInNaira: fee,
    recipient: _recipient,
    narration: '',
    createdAt: DateTime(2026, 11, 24, 15, 42),
  );
}

DioException _dioError(
  DioExceptionType type, {
  int? statusCode,
  Object? data,
}) {
  final request = RequestOptions(path: '/bank-transfers');
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

Matcher _throwsFailure(
  BankTransferErrorCode code, {
  required bool outcomeUnknown,
}) {
  return throwsA(
    isA<BankTransferFailure>()
        .having((f) => f.code, 'code', code)
        .having((f) => f.isOutcomeUnknown, 'isOutcomeUnknown', outcomeUnknown),
  );
}

void main() {
  late _MockBankTransferService service;
  late BankTransferRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_draft);
    registerFallbackValue(_access);
  });

  setUp(() {
    service = _MockBankTransferService();
    repository = BankTransferRepositoryImpl(service);
  });

  When<Future<BankTransferReceipt>> stubTransfer() {
    return when(
      () => service.transfer(
        idempotencyKey: any(named: 'idempotencyKey'),
        draft: any(named: 'draft'),
        pin: any(named: 'pin'),
      ),
    );
  }

  Future<BankTransferReceipt> transfer() {
    return repository.transfer(
      idempotencyKey: 'key-1',
      draft: _draft,
      pin: '1234',
    );
  }

  group('getBanks', () {
    test('sorts the banks by name and caches them', () async {
      when(
        () => service.getBanks(),
      ).thenAnswer((_) async => [_zenith, _access]);

      final first = await repository.getBanks();
      final second = await repository.getBanks();

      expect(first, [_access, _zenith]);
      expect(second, first);
      verify(() => service.getBanks()).called(1);
    });

    test('returns the stale list when a refresh fails', () async {
      var now = DateTime(2026, 11, 24, 9);
      repository = BankTransferRepositoryImpl(
        service,
        bankCacheDuration: const Duration(hours: 1),
        now: () => now,
      );

      when(() => service.getBanks()).thenAnswer((_) async => [_access]);
      await repository.getBanks();

      now = now.add(const Duration(hours: 2));
      when(
        () => service.getBanks(),
      ).thenThrow(_dioError(DioExceptionType.connectionError));

      expect(await repository.getBanks(), [_access]);
    });

    test('fails when there is no cached list to fall back on', () async {
      when(
        () => service.getBanks(),
      ).thenThrow(_dioError(DioExceptionType.connectionError));

      await expectLater(
        repository.getBanks(),
        _throwsFailure(BankTransferErrorCode.network, outcomeUnknown: true),
      );
    });
  });

  group('resolveRecipient', () {
    test('rejects a response for a different account', () async {
      when(
        () => service.resolveAccount(
          bank: any(named: 'bank'),
          accountNumber: any(named: 'accountNumber'),
        ),
      ).thenAnswer(
        (_) async => const BankRecipient(
          bank: _access,
          accountNumber: '0987654321',
          accountName: 'Someone Else',
        ),
      );

      await expectLater(
        repository.resolveRecipient(bank: _access, accountNumber: '0123456789'),
        _throwsFailure(
          BankTransferErrorCode.unexpectedResponse,
          outcomeUnknown: true,
        ),
      );
    });

    test('maps 404 to recipientNotFound', () async {
      when(
        () => service.resolveAccount(
          bank: any(named: 'bank'),
          accountNumber: any(named: 'accountNumber'),
        ),
      ).thenThrow(_dioError(DioExceptionType.badResponse, statusCode: 404));

      await expectLater(
        repository.resolveRecipient(bank: _access, accountNumber: '0123456789'),
        _throwsFailure(
          BankTransferErrorCode.recipientNotFound,
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

    test('maps INSUFFICIENT_FUNDS', () async {
      stubTransfer().thenThrow(
        _dioError(
          DioExceptionType.badResponse,
          statusCode: 422,
          data: {'code': 'INSUFFICIENT_FUNDS'},
        ),
      );

      await expectLater(
        transfer(),
        _throwsFailure(
          BankTransferErrorCode.insufficientFunds,
          outcomeUnknown: false,
        ),
      );
    });

    test('maps FEE_CHANGED', () async {
      stubTransfer().thenThrow(
        _dioError(
          DioExceptionType.badResponse,
          statusCode: 409,
          data: {'code': 'FEE_CHANGED'},
        ),
      );

      await expectLater(
        transfer(),
        _throwsFailure(
          BankTransferErrorCode.feeChanged,
          outcomeUnknown: false,
        ),
      );
    });

    test('treats a timeout as an unknown outcome', () async {
      stubTransfer().thenThrow(_dioError(DioExceptionType.receiveTimeout));

      await expectLater(
        transfer(),
        _throwsFailure(BankTransferErrorCode.network, outcomeUnknown: true),
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
          isA<BankTransferFailure>()
              .having((f) => f.code, 'code', BankTransferErrorCode.server)
              .having((f) => f.message, 'message', isNot(contains('Query'))),
        ),
      );
    });

    test(
      'treats a receipt with a different fee as an unknown outcome',
      () async {
        stubTransfer().thenAnswer((_) async => _receipt(fee: 100));

        await expectLater(
          transfer(),
          _throwsFailure(
            BankTransferErrorCode.unexpectedResponse,
            outcomeUnknown: true,
          ),
        );
      },
    );
  });

  group('getTransfer', () {
    test('returns the latest receipt', () async {
      when(
        () => service.getTransfer('REF-1'),
      ).thenAnswer((_) async => _receipt());

      expect((await repository.getTransfer('REF-1')).reference, 'REF-1');
    });

    test('rejects a receipt for a different transfer', () async {
      when(
        () => service.getTransfer('REF-1'),
      ).thenAnswer((_) async => _receipt(reference: 'REF-2'));

      await expectLater(
        repository.getTransfer('REF-1'),
        _throwsFailure(
          BankTransferErrorCode.unexpectedResponse,
          outcomeUnknown: true,
        ),
      );
    });
  });
}
