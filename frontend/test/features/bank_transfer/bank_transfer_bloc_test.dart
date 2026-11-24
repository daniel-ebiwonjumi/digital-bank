import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_app/features/bank_transfer/data/models/bank_transfer_failure.dart';
import 'package:your_app/features/bank_transfer/data/models/bank_transfer_models.dart';
import 'package:your_app/features/bank_transfer/data/repositories/mock_bank_transfer_repository.dart';
import 'package:your_app/features/bank_transfer/presentation/bloc/bank_transfer_bloc.dart';
import 'package:your_app/features/bank_transfer/presentation/bloc/bank_transfer_event.dart';
import 'package:your_app/features/bank_transfer/presentation/bloc/bank_transfer_state.dart';

// bloc_test closes the bloc one event-loop turn after `act`, so flows that
// wait on timers need a little time to finish.
const _wait = Duration(milliseconds: 50);

const _access = Bank(code: '044', name: 'Access Bank');
const _kuda = Bank(code: '50211', name: 'Kuda Microfinance Bank');

const _recipient = BankRecipient(
  bank: _access,
  accountNumber: '0123456789',
  accountName: 'Ada Obi',
);

const _draft = BankTransferDraft(
  recipient: _recipient,
  amountInNaira: 5000,
  feeInNaira: 26.88,
  narration: 'Rent',
);

const _formWithBank = BankTransferEditing(
  banks: MockBankTransferRepository.defaultBanks,
  selectedBank: _access,
);

const _resolvedForm = BankTransferEditing(
  banks: MockBankTransferRepository.defaultBanks,
  selectedBank: _access,
  accountNumber: '0123456789',
  lookupStatus: RecipientLookupStatus.resolved,
  recipient: _recipient,
);

MockBankTransferRepository _newRepository({
  double feeInNaira = 26.88,
  BankTransferStatus initialStatus = BankTransferStatus.pending,
  BankTransferStatus finalStatus = BankTransferStatus.success,
  BankTransferFailure? banksFailure,
  BankTransferFailure? feeFailure,
  List<BankTransferFailure>? transferFailures,
}) {
  return MockBankTransferRepository(
    latency: Duration.zero,
    feeInNaira: feeInNaira,
    initialStatus: initialStatus,
    finalStatus: finalStatus,
    banksFailure: banksFailure,
    feeFailure: feeFailure,
    transferFailures: transferFailures,
  );
}

BankTransferBloc _newBloc(
  MockBankTransferRepository repository, {
  int maxStatusChecks = 8,
}) {
  var counter = 0;
  return BankTransferBloc(
    repository: repository,
    idempotencyKeyGenerator: () => 'key-${++counter}',
    maxStatusChecks: maxStatusChecks,
    statusCheckDelay: Duration.zero,
  );
}

void main() {
  late MockBankTransferRepository repository;

  setUp(() => repository = _newRepository());

  group('bank list', () {
    blocTest<BankTransferBloc, BankTransferState>(
      'loads the banks',
      build: () => _newBloc(repository),
      act: (bloc) => bloc.add(const BanksRequested()),
      wait: _wait,
      expect: () => [
        const BankTransferEditing(
          banks: MockBankTransferRepository.defaultBanks,
        ),
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'reports a failure to load the banks',
      build: () {
        repository = _newRepository(
          banksFailure: BankTransferFailure(BankTransferErrorCode.network),
        );
        return _newBloc(repository);
      },
      act: (bloc) => bloc.add(const BanksRequested()),
      wait: _wait,
      expect: () => [
        BankTransferBanksFailed(BankTransferErrorCode.network.message),
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'can retry after a failure',
      build: () => _newBloc(repository),
      seed: () => const BankTransferBanksFailed('failed'),
      act: (bloc) => bloc.add(const BanksRequested()),
      wait: _wait,
      expect: () => [
        const BankTransferLoadingBanks(),
        const BankTransferEditing(
          banks: MockBankTransferRepository.defaultBanks,
        ),
      ],
    );
  });

  group('recipient lookup', () {
    blocTest<BankTransferBloc, BankTransferState>(
      'resolves the recipient once the bank and 10 digits are set',
      build: () => _newBloc(repository),
      seed: () => _formWithBank,
      act: (bloc) => bloc.add(const AccountNumberChanged('0123456789')),
      wait: _wait,
      expect: () => [
        _formWithBank.copyWith(
          accountNumber: '0123456789',
          lookupStatus: RecipientLookupStatus.loading,
        ),
        _resolvedForm,
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'reports an account that cannot be verified',
      build: () => _newBloc(repository),
      seed: () => _formWithBank,
      act: (bloc) => bloc.add(const AccountNumberChanged('1111111111')),
      wait: _wait,
      expect: () => [
        _formWithBank.copyWith(
          accountNumber: '1111111111',
          lookupStatus: RecipientLookupStatus.loading,
        ),
        _formWithBank.copyWith(
          accountNumber: '1111111111',
          lookupStatus: RecipientLookupStatus.failed,
          lookupMessage: BankTransferErrorCode.recipientNotFound.message,
        ),
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'clears the recipient when a digit is deleted',
      build: () => _newBloc(repository),
      seed: () => _resolvedForm,
      act: (bloc) => bloc.add(const AccountNumberChanged('012345678')),
      wait: _wait,
      expect: () => [
        _resolvedForm.copyWith(
          accountNumber: '012345678',
          lookupStatus: RecipientLookupStatus.idle,
          clearRecipient: true,
        ),
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'checks the account again when the bank changes',
      build: () => _newBloc(repository),
      seed: () => _resolvedForm,
      act: (bloc) => bloc.add(const BankSelected(_kuda)),
      wait: _wait,
      expect: () => [
        _resolvedForm.copyWith(
          selectedBank: _kuda,
          lookupStatus: RecipientLookupStatus.loading,
          clearRecipient: true,
        ),
        _resolvedForm.copyWith(
          selectedBank: _kuda,
          lookupStatus: RecipientLookupStatus.failed,
          lookupMessage: BankTransferErrorCode.recipientNotFound.message,
          clearRecipient: true,
        ),
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'ignores input while reviewing',
      build: () => _newBloc(repository),
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) => bloc.add(const AccountNumberChanged('1')),
      wait: _wait,
      expect: () => <BankTransferState>[],
    );
  });

  group('review', () {
    blocTest<BankTransferBloc, BankTransferState>(
      'fetches the fee and moves to review with a trimmed narration',
      build: () => _newBloc(repository),
      seed: () => _resolvedForm,
      act: (bloc) => bloc.add(
        const BankTransferReviewRequested(
          amountInNaira: 5000,
          narration: '  Rent  ',
        ),
      ),
      wait: _wait,
      expect: () => [
        _resolvedForm.copyWith(isQuoting: true),
        const BankTransferReviewing(_draft),
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'shows an error when the fee cannot be fetched',
      build: () {
        repository = _newRepository(
          feeFailure: BankTransferFailure(BankTransferErrorCode.network),
        );
        return _newBloc(repository);
      },
      seed: () => _resolvedForm,
      act: (bloc) => bloc.add(
        const BankTransferReviewRequested(amountInNaira: 5000, narration: ''),
      ),
      wait: _wait,
      expect: () => [
        _resolvedForm.copyWith(isQuoting: true),
        _resolvedForm.copyWith(
          errorMessage: BankTransferErrorCode.network.message,
        ),
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'ignores amounts outside the limits',
      build: () => _newBloc(repository),
      seed: () => _resolvedForm,
      act: (bloc) => bloc.add(
        const BankTransferReviewRequested(amountInNaira: 50, narration: ''),
      ),
      wait: _wait,
      expect: () => <BankTransferState>[],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'ignores Continue while the recipient is not verified',
      build: () => _newBloc(repository),
      seed: () => _formWithBank,
      act: (bloc) => bloc.add(
        const BankTransferReviewRequested(amountInNaira: 5000, narration: ''),
      ),
      wait: _wait,
      expect: () => <BankTransferState>[],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'goes back to editing from the review step',
      build: () => _newBloc(repository),
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) => bloc.add(const BankTransferEditRequested()),
      wait: _wait,
      // The bank list is empty because this bloc never loaded it.
      expect: () => [
        const BankTransferEditing(
          banks: [],
          selectedBank: _access,
          accountNumber: '0123456789',
          lookupStatus: RecipientLookupStatus.resolved,
          recipient: _recipient,
        ),
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'does not allow editing after an unknown outcome',
      build: () => _newBloc(repository),
      seed: () => const BankTransferOutcomeUnknown(_draft, 'unknown'),
      act: (bloc) => bloc.add(const BankTransferEditRequested()),
      wait: _wait,
      expect: () => <BankTransferState>[],
    );
  });

  group('confirming', () {
    blocTest<BankTransferBloc, BankTransferState>(
      'follows an accepted transfer until it succeeds',
      build: () => _newBloc(repository),
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) => bloc.add(const BankTransferConfirmed('1234')),
      wait: _wait,
      expect: () => [
        const BankTransferSubmitting(_draft),
        isA<BankTransferProcessing>(),
        isA<BankTransferSucceeded>(),
      ],
      verify: (_) => expect(repository.transfersCreated, 1),
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'succeeds immediately when the bank confirms right away',
      build: () {
        repository = _newRepository(initialStatus: BankTransferStatus.success);
        return _newBloc(repository);
      },
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) => bloc.add(const BankTransferConfirmed('1234')),
      wait: _wait,
      expect: () => [
        const BankTransferSubmitting(_draft),
        isA<BankTransferSucceeded>(),
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'ends as pending when the transfer does not settle in time',
      build: () {
        repository = _newRepository(finalStatus: BankTransferStatus.pending);
        return _newBloc(repository, maxStatusChecks: 3);
      },
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) => bloc.add(const BankTransferConfirmed('1234')),
      wait: _wait,
      expect: () => [
        const BankTransferSubmitting(_draft),
        isA<BankTransferProcessing>(),
        isA<BankTransferPending>(),
      ],
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'reports an unsuccessful transfer and the money is returned',
      build: () {
        repository = _newRepository(finalStatus: BankTransferStatus.failed);
        return _newBloc(repository);
      },
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) => bloc.add(const BankTransferConfirmed('1234')),
      wait: _wait,
      expect: () => [
        const BankTransferSubmitting(_draft),
        isA<BankTransferProcessing>(),
        isA<BankTransferUnsuccessful>(),
      ],
      verify: (_) => expect(repository.balanceInNaira, 250000),
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'stays reviewable after a wrong PIN',
      build: () => _newBloc(repository),
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) => bloc.add(const BankTransferConfirmed('0000')),
      wait: _wait,
      expect: () => [
        const BankTransferSubmitting(_draft),
        BankTransferFailed(
          _draft,
          BankTransferErrorCode.invalidPin.message,
          BankTransferErrorCode.invalidPin,
        ),
      ],
      verify: (_) => expect(repository.transfersCreated, 0),
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'rejects a malformed PIN without calling the backend',
      build: () => _newBloc(repository),
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) => bloc.add(const BankTransferConfirmed('12')),
      wait: _wait,
      expect: () => [
        const BankTransferFailed(
          _draft,
          'Enter your 4-digit PIN.',
          BankTransferErrorCode.invalidPin,
        ),
      ],
      verify: (_) => expect(repository.receivedKeys, isEmpty),
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'requires a new review when the fee changed',
      build: () {
        repository = _newRepository(feeInNaira: 30);
        return _newBloc(repository);
      },
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) async {
        bloc.add(const BankTransferConfirmed('1234'));
        await bloc.stream.firstWhere((s) => s is BankTransferFailed);
        // A second confirmation must not reach the backend.
        bloc.add(const BankTransferConfirmed('1234'));
      },
      wait: _wait,
      expect: () => [
        const BankTransferSubmitting(_draft),
        BankTransferFailed(
          _draft,
          BankTransferErrorCode.feeChanged.message,
          BankTransferErrorCode.feeChanged,
        ),
      ],
      verify: (_) => expect(repository.receivedKeys, hasLength(1)),
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'sends only one request when the confirm button is tapped twice',
      build: () => _newBloc(repository),
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) {
        bloc
          ..add(const BankTransferConfirmed('1234'))
          ..add(const BankTransferConfirmed('1234'));
      },
      wait: _wait,
      expect: () => [
        const BankTransferSubmitting(_draft),
        isA<BankTransferProcessing>(),
        isA<BankTransferSucceeded>(),
      ],
      verify: (_) => expect(repository.receivedKeys, hasLength(1)),
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'reuses the same idempotency key when retrying after an unknown outcome',
      build: () {
        repository = _newRepository(
          transferFailures: [
            BankTransferFailure(BankTransferErrorCode.network),
          ],
        );
        return _newBloc(repository);
      },
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) async {
        bloc.add(const BankTransferConfirmed('1234'));
        await bloc.stream.firstWhere((s) => s is BankTransferOutcomeUnknown);
        bloc.add(const BankTransferConfirmed('1234'));
      },
      wait: _wait,
      expect: () => [
        const BankTransferSubmitting(_draft),
        BankTransferOutcomeUnknown(
          _draft,
          BankTransferErrorCode.network.message,
        ),
        const BankTransferSubmitting(_draft),
        isA<BankTransferProcessing>(),
        isA<BankTransferSucceeded>(),
      ],
      verify: (_) {
        expect(repository.receivedKeys, ['key-1', 'key-1']);
        expect(repository.transfersCreated, 1);
      },
    );

    blocTest<BankTransferBloc, BankTransferState>(
      'uses a new idempotency key after a definite failure',
      build: () {
        repository = _newRepository(
          transferFailures: [
            BankTransferFailure(BankTransferErrorCode.invalidPin),
          ],
        );
        return _newBloc(repository);
      },
      seed: () => const BankTransferReviewing(_draft),
      act: (bloc) async {
        bloc.add(const BankTransferConfirmed('1234'));
        await bloc.stream.firstWhere((s) => s is BankTransferFailed);
        bloc.add(const BankTransferConfirmed('1234'));
      },
      wait: _wait,
      expect: () => [
        const BankTransferSubmitting(_draft),
        BankTransferFailed(
          _draft,
          BankTransferErrorCode.invalidPin.message,
          BankTransferErrorCode.invalidPin,
        ),
        const BankTransferSubmitting(_draft),
        isA<BankTransferProcessing>(),
        isA<BankTransferSucceeded>(),
      ],
      verify: (_) => expect(repository.receivedKeys, ['key-1', 'key-2']),
    );
  });
}
