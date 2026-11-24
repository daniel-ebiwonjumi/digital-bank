import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:your_app/core/errors/failure.dart';
import 'package:your_app/features/fund_account/data/models/funding_models.dart';
import 'package:your_app/features/fund_account/data/repositories/fund_account_repository_impl.dart';
import 'package:your_app/features/fund_account/data/services/fund_account_service.dart';

class _MockFundAccountService extends Mock implements FundAccountService {}

void main() {
  late _MockFundAccountService service;
  late FundAccountRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(FundingMethod.card));

  setUp(() {
    service = _MockFundAccountService();
    repository = FundAccountRepositoryImpl(service);
  });

  DioException dioError(
    DioExceptionType type, {
    int? statusCode,
    Object? data,
  }) {
    final request = RequestOptions(path: '/wallet/fund/initialize');
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

  void stubInitializeThrows(Object error) {
    when(
      () => service.initialize(
        amountInNaira: any(named: 'amountInNaira'),
        method: any(named: 'method'),
      ),
    ).thenThrow(error);
  }

  Future<FundingSession> initialize() {
    return repository.initializeFunding(
      amountInNaira: 5000,
      method: FundingMethod.card,
    );
  }

  Matcher failureWith(String text) {
    return throwsA(
      isA<Failure>().having((f) => f.message, 'message', contains(text)),
    );
  }

  group('FundAccountRepositoryImpl.initializeFunding', () {
    test('returns the session on success', () async {
      const session = FundingSession(
        authorizationUrl: 'https://example.com',
        reference: 'ref_1',
      );
      when(
        () => service.initialize(
          amountInNaira: any(named: 'amountInNaira'),
          method: any(named: 'method'),
        ),
      ).thenAnswer((_) async => session);

      expect(await initialize(), session);
    });

    test('maps timeouts to a network failure', () async {
      stubInitializeThrows(dioError(DioExceptionType.connectionTimeout));

      await expectLater(initialize(), failureWith('Network problem'));
    });

    test('asks the user to log in again on 401', () async {
      stubInitializeThrows(
        dioError(DioExceptionType.badResponse, statusCode: 401),
      );

      await expectLater(initialize(), failureWith('log in again'));
    });

    test('uses the validation messages sent by the server on 422', () async {
      stubInitializeThrows(
        dioError(
          DioExceptionType.badResponse,
          statusCode: 422,
          data: {
            'message': ['Amount must be positive', 'Channel is invalid'],
          },
        ),
      );

      await expectLater(
        initialize(),
        failureWith('Amount must be positive\nChannel is invalid'),
      );
    });

    test(
      'hides server error details behind a generic message on 500',
      () async {
        stubInitializeThrows(
          dioError(
            DioExceptionType.badResponse,
            statusCode: 500,
            data: {'message': 'QueryFailedError: relation does not exist'},
          ),
        );

        await expectLater(
          initialize(),
          failureWith('servers are having a problem'),
        );
      },
    );

    test('turns malformed responses into a failure', () async {
      stubInitializeThrows(const FormatException('bad json'));

      await expectLater(initialize(), failureWith('Unexpected response'));
    });
  });
}
