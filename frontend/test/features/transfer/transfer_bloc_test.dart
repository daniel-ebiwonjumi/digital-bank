import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_app/features/transfer/data/models/transfer_failure.dart';
import 'package:your_app/features/transfer/data/models/transfer_models.dart';
import 'package:your_app/features/transfer/data/repositories/mock_transfer_repository.dart';
import 'package:your_app/features/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:your_app/features/transfer/presentation/bloc/transfer_event.dart';
import 'package:your_app/features/transfer/presentation/bloc/transfer_state.dart';

const _recipient = Recipient(
  accountNumber: '0123456789',
  accountName: 'Ada Obi',
);

const _draft = TransferDraft(
  recipient: _recipient,
  amountInNaira: 5000,
  narration: 'Rent',
);

MockTransferRepository _newRepository({List<TransferFailure>? failures}) {
  return MockTransferRepository(
    latency: Duration.zero,
    transferFailures: failures,
  );
}

TransferBloc _newBloc(MockTransferRepository repository) {
  var counter = 0;
  return TransferBloc(
    repository: repository,
    idempotencyKeyGenerator: () => 'key-${++counter}',
  );
}

void main() {
  late MockTransferRepository repository;

  setUp(() => repository = _newRepository());

  group('recipient lookup', () {
    blocTest<TransferBloc, TransferState>(
      'resolves the recipient once 10 digits are entered',
      build: () => _newBloc(repository),
      act: (bloc) =>
          bloc.add(const RecipientAccountNumberChanged('0123456789')),
      expect: () => [
        const TransferLookingUpRecipient('0123456789'),
        const TransferRecipientResolved(_recipient),
      ],
    );

    blocTest<TransferBloc, TransferState>(
      'does nothing while the account number is incomplete',
      build: () => _newBloc(repository),
      act: (bloc) => bloc.add(const RecipientAccountNumberChanged('01234')),
      expect: () => <TransferState>[],
    );

    blocTest<TransferBloc, TransferState>(
      'reports an unknown account',
      build: () => _newBloc(repository),
      act: (bloc) =>
          bloc.add(const RecipientAccountNumberChanged('1111111111')),
      expect: () => [
        const TransferLookingUpRecipient('1111111111'),
        TransferRecipientLookupFailed(
          '1111111111',
          TransferErrorCode.recipientNotFound.message,
        ),
      ],
    );

    blocTest<TransferBloc, TransferState>(
      'goes back to the initial state when a digit is deleted',
      build: () => _newBloc(repository),
      seed: () => const TransferRecipientResolved(_recipient),
      act: (bloc) => bloc.add(const RecipientAccountNumberChanged('012345678')),
      expect: () => [const TransferInitial()],
    );
  });

  group('review', () {
    blocTest<TransferBloc, TransferState>(
      'moves to review with a trimmed narration',
      build: () => _newBloc(repository),
      seed: () => const TransferRecipientResolved(_recipient),
      act: (bloc) => bloc.add(
        const TransferReviewRequested(
          amountInNaira: 5000,
          narration: '  Rent  ',
        ),
      ),
      expect: () => [const TransferReviewing(_draft)],
    );

    blocTest<TransferBloc, TransferState>(
      'ignores amounts outside the limits',
      build: () => _newBloc(repository),
      seed: () => const TransferRecipientResolved(_recipient),
      act: (bloc) => bloc.add(
        const TransferReviewRequested(amountInNaira: 0.5, narration: ''),
      ),
      expect: () => <TransferState>[],
    );

    blocTest<TransferBloc, TransferState>(
      'goes back to editing from the review step',
      build: () => _newBloc(repository),
      seed: () => const TransferReviewing(_draft),
      act: (bloc) => bloc.add(const TransferEditRequested()),
      expect: () => [const TransferRecipientResolved(_recipient)],
    );

    blocTest<TransferBloc, TransferState>(
      'does not allow editing after an unknown outcome',
      build: () => _newBloc(repository),
      seed: () => const TransferOutcomeUnknown(_draft, 'unknown'),
      act: (bloc) => bloc.add(const TransferEditRequested()),
      expect: () => <TransferState>[],
    );
  });

  group('confirming', () {
    blocTest<TransferBloc, TransferState>(
      'completes the transfer',
      build: () => _newBloc(repository),
      seed: () => const TransferReviewing(_draft),
      act: (bloc) => bloc.add(const TransferConfirmed('1234')),
      expect: () => [
        const TransferSubmitting(_draft),
        isA<TransferSucceeded>(),
      ],
      verify: (_) => expect(repository.transfersCreated, 1),
    );

    blocTest<TransferBloc, TransferState>(
      'stays reviewable after a wrong PIN',
      build: () => _newBloc(repository),
      seed: () => const TransferReviewing(_draft),
      act: (bloc) => bloc.add(const TransferConfirmed('0000')),
      expect: () => [
        const TransferSubmitting(_draft),
        TransferFailed(
          _draft,
          TransferErrorCode.invalidPin.message,
          TransferErrorCode.invalidPin,
        ),
      ],
      verify: (_) => expect(repository.transfersCreated, 0),
    );

    blocTest<TransferBloc, TransferState>(
      'rejects a malformed PIN without calling the backend',
      build: () => _newBloc(repository),
      seed: () => const TransferReviewing(_draft),
      act: (bloc) => bloc.add(const TransferConfirmed('12')),
      expect: () => [
        const TransferFailed(
          _draft,
          'Enter your 4-digit PIN.',
          TransferErrorCode.invalidPin,
        ),
      ],
      verify: (_) => expect(repository.receivedKeys, isEmpty),
    );

    blocTest<TransferBloc, TransferState>(
      'sends only one request when the confirm button is tapped twice',
      build: () => _newBloc(repository),
      seed: () => const TransferReviewing(_draft),
      act: (bloc) {
        bloc
          ..add(const TransferConfirmed('1234'))
          ..add(const TransferConfirmed('1234'));
      },
      expect: () => [
        const TransferSubmitting(_draft),
        isA<TransferSucceeded>(),
      ],
      verify: (_) => expect(repository.receivedKeys, hasLength(1)),
    );

    blocTest<TransferBloc, TransferState>(
      'reuses the same idempotency key when retrying after an unknown outcome',
      build: () {
        repository = _newRepository(
          failures: [TransferFailure(TransferErrorCode.network)],
        );
        return _newBloc(repository);
      },
      seed: () => const TransferReviewing(_draft),
      act: (bloc) async {
        bloc.add(const TransferConfirmed('1234'));
        await bloc.stream.firstWhere((s) => s is TransferOutcomeUnknown);
        bloc.add(const TransferConfirmed('1234'));
      },
      expect: () => [
        const TransferSubmitting(_draft),
        TransferOutcomeUnknown(_draft, TransferErrorCode.network.message),
        const TransferSubmitting(_draft),
        isA<TransferSucceeded>(),
      ],
      verify: (_) {
        expect(repository.receivedKeys, ['key-1', 'key-1']);
        expect(repository.transfersCreated, 1);
      },
    );

    blocTest<TransferBloc, TransferState>(
      'uses a new idempotency key after a definite failure',
      build: () {
        repository = _newRepository(
          failures: [TransferFailure(TransferErrorCode.invalidPin)],
        );
        return _newBloc(repository);
      },
      seed: () => const TransferReviewing(_draft),
      act: (bloc) async {
        bloc.add(const TransferConfirmed('1234'));
        await bloc.stream.firstWhere((s) => s is TransferFailed);
        bloc.add(const TransferConfirmed('1234'));
      },
      expect: () => [
        const TransferSubmitting(_draft),
        TransferFailed(
          _draft,
          TransferErrorCode.invalidPin.message,
          TransferErrorCode.invalidPin,
        ),
        const TransferSubmitting(_draft),
        isA<TransferSucceeded>(),
      ],
      verify: (_) => expect(repository.receivedKeys, ['key-1', 'key-2']),
    );
  });
}
