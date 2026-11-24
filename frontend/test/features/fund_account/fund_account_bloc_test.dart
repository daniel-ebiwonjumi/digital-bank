import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_app/core/errors/failure.dart';
import 'package:your_app/features/fund_account/data/models/funding_models.dart';
import 'package:your_app/features/fund_account/data/repositories/mock_fund_account_repository.dart';
import 'package:your_app/features/fund_account/presentation/bloc/fund_account_bloc.dart';
import 'package:your_app/features/fund_account/presentation/bloc/fund_account_event.dart';
import 'package:your_app/features/fund_account/presentation/bloc/fund_account_state.dart';

const _session = FundingSession(
  authorizationUrl: 'https://example.com',
  reference: 'ref_1',
);

FundAccountBloc _buildBloc({
  List<FundingStatusType> verifySequence = const [FundingStatusType.success],
  int verifyErrorCount = 0,
  Failure? initializeError,
  int maxVerifyAttempts = 5,
}) {
  return FundAccountBloc(
    repository: MockFundAccountRepository(
      latency: Duration.zero,
      initializeError: initializeError,
      verifyErrorCount: verifyErrorCount,
      verifySequence: verifySequence,
    ),
    maxVerifyAttempts: maxVerifyAttempts,
    verifyRetryDelay: Duration.zero,
  );
}

void main() {
  group('FundAccountBloc', () {
    blocTest<FundAccountBloc, FundAccountState>(
      'moves to AwaitingPayment after initializing',
      build: () => _buildBloc(),
      act: (bloc) => bloc.add(
        const FundingSubmitted(
          amountInNaira: 5000,
          method: FundingMethod.card,
        ),
      ),
      expect: () => [
        const FundAccountInitializing(),
        isA<FundAccountAwaitingPayment>(),
      ],
    );

    blocTest<FundAccountBloc, FundAccountState>(
      'rejects an amount outside the limits without calling the backend',
      build: () => _buildBloc(),
      act: (bloc) => bloc.add(
        const FundingSubmitted(
          amountInNaira: 50,
          method: FundingMethod.card,
        ),
      ),
      expect: () => [const FundAccountFailure('Enter a valid amount.')],
    );

    blocTest<FundAccountBloc, FundAccountState>(
      'emits Failure when initializing fails',
      build: () => _buildBloc(initializeError: const Failure('No internet')),
      act: (bloc) => bloc.add(
        const FundingSubmitted(
          amountInNaira: 5000,
          method: FundingMethod.bankTransfer,
        ),
      ),
      expect: () => [
        const FundAccountInitializing(),
        const FundAccountFailure('No internet'),
      ],
    );

    blocTest<FundAccountBloc, FundAccountState>(
      'ignores a new submission while verifying',
      build: () => _buildBloc(),
      seed: () => const FundAccountVerifying('ref_1'),
      act: (bloc) => bloc.add(
        const FundingSubmitted(
          amountInNaira: 5000,
          method: FundingMethod.card,
        ),
      ),
      expect: () => <FundAccountState>[],
    );

    blocTest<FundAccountBloc, FundAccountState>(
      'confirms the payment after a pending check',
      build: () => _buildBloc(
        verifySequence: const [
          FundingStatusType.pending,
          FundingStatusType.success,
        ],
      ),
      seed: () => const FundAccountAwaitingPayment(_session),
      act: (bloc) => bloc.add(const PaymentWindowClosed()),
      expect: () => [
        const FundAccountVerifying('ref_1'),
        const FundAccountSuccess('ref_1'),
      ],
    );

    blocTest<FundAccountBloc, FundAccountState>(
      'retries after a network error and then confirms',
      build: () => _buildBloc(verifyErrorCount: 1),
      seed: () => const FundAccountAwaitingPayment(_session),
      act: (bloc) => bloc.add(const PaymentWindowClosed()),
      expect: () => [
        const FundAccountVerifying('ref_1'),
        const FundAccountSuccess('ref_1'),
      ],
    );

    blocTest<FundAccountBloc, FundAccountState>(
      'ends as Pending when the backend never confirms',
      build: () => _buildBloc(
        verifySequence: const [FundingStatusType.pending],
        maxVerifyAttempts: 3,
      ),
      seed: () => const FundAccountAwaitingPayment(_session),
      act: (bloc) => bloc.add(const PaymentWindowClosed()),
      expect: () => [
        const FundAccountVerifying('ref_1'),
        const FundAccountPending('ref_1'),
      ],
    );

    blocTest<FundAccountBloc, FundAccountState>(
      'ends as Pending, not Failure, when verification keeps erroring',
      build: () => _buildBloc(verifyErrorCount: 10, maxVerifyAttempts: 3),
      seed: () => const FundAccountAwaitingPayment(_session),
      act: (bloc) => bloc.add(const PaymentWindowClosed()),
      expect: () => [
        const FundAccountVerifying('ref_1'),
        const FundAccountPending('ref_1'),
      ],
    );

    blocTest<FundAccountBloc, FundAccountState>(
      'emits Failure when the backend reports the payment failed',
      build: () => _buildBloc(verifySequence: const [FundingStatusType.failed]),
      seed: () => const FundAccountAwaitingPayment(_session),
      act: (bloc) => bloc.add(const PaymentWindowClosed()),
      expect: () => [
        const FundAccountVerifying('ref_1'),
        const FundAccountFailure('Payment was not completed.'),
      ],
    );
  });
}
