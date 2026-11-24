import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/idempotency_key.dart';
// Only the PIN rules are shared with the same-bank transfer feature.
import '../../../transfer/data/models/transfer_models.dart' show TransferRules;
import '../../data/models/bank_transfer_failure.dart';
import '../../data/models/bank_transfer_models.dart';
import '../../data/repositories/bank_transfer_repository.dart';
import 'bank_transfer_event.dart';
import 'bank_transfer_state.dart';

class BankTransferBloc extends Bloc<BankTransferEvent, BankTransferState> {
  BankTransferBloc({
    required BankTransferRepository repository,
    String Function() idempotencyKeyGenerator = generateIdempotencyKey,
    this.maxStatusChecks = 8,
    this.statusCheckDelay = const Duration(seconds: 4),
  }) : assert(maxStatusChecks > 0),
       _repository = repository,
       _generateKey = idempotencyKeyGenerator,
       super(const BankTransferLoadingBanks()) {
    on<BanksRequested>(_onBanksRequested, transformer: droppable());
    // A newer bank or account number cancels the lookup in flight, so a slow,
    // stale response can never overwrite a newer one.
    on<RecipientInputEvent>(_onRecipientInput, transformer: restartable());
    on<BankTransferReviewRequested>(
      _onReviewRequested,
      transformer: droppable(),
    );
    on<BankTransferEditRequested>(_onEditRequested);
    // Extra taps while a transfer is in flight are dropped.
    on<BankTransferConfirmed>(_onConfirmed, transformer: droppable());
  }

  final BankTransferRepository _repository;
  final String Function() _generateKey;

  /// How many times to ask for the status of an accepted transfer, and how
  /// long to wait between checks, before giving up with "pending".
  final int maxStatusChecks;
  final Duration statusCheckDelay;

  List<Bank> _banks = const [];

  /// Identifies one transfer attempt. It is created when the review step
  /// opens, kept when the outcome is unknown (so a retry cannot duplicate the
  /// transfer) and replaced after a definite failure or when editing.
  String? _idempotencyKey;

  Future<void> _onBanksRequested(
    BanksRequested event,
    Emitter<BankTransferState> emit,
  ) async {
    if (state is! BankTransferLoadingBanks &&
        state is! BankTransferBanksFailed) {
      return;
    }
    if (state is! BankTransferLoadingBanks) {
      emit(const BankTransferLoadingBanks());
    }

    try {
      _banks = await _repository.getBanks();
      emit(BankTransferEditing(banks: _banks));
    } on BankTransferFailure catch (failure) {
      emit(BankTransferBanksFailed(failure.message));
    }
  }

  Future<void> _onRecipientInput(
    RecipientInputEvent event,
    Emitter<BankTransferState> emit,
  ) async {
    final current = state;
    if (current is! BankTransferEditing || current.isQuoting) return;

    final (bank, accountNumber) = switch (event) {
      BankSelected(:final bank) => (bank, current.accountNumber),
      AccountNumberChanged(:final accountNumber) => (
        current.selectedBank,
        accountNumber.trim(),
      ),
    };

    // Whatever changed, the previous recipient no longer applies.
    final base = current.copyWith(
      selectedBank: bank,
      accountNumber: accountNumber,
      lookupStatus: RecipientLookupStatus.idle,
      clearRecipient: true,
      clearLookupMessage: true,
      clearError: true,
    );

    if (bank == null ||
        !BankTransferRules.isValidAccountNumber(accountNumber)) {
      emit(base);
      return;
    }

    emit(base.copyWith(lookupStatus: RecipientLookupStatus.loading));
    try {
      final recipient = await _repository.resolveRecipient(
        bank: bank,
        accountNumber: accountNumber,
      );
      emit(
        base.copyWith(
          lookupStatus: RecipientLookupStatus.resolved,
          recipient: recipient,
        ),
      );
    } on BankTransferFailure catch (failure) {
      emit(
        base.copyWith(
          lookupStatus: RecipientLookupStatus.failed,
          lookupMessage: failure.message,
        ),
      );
    }
  }

  Future<void> _onReviewRequested(
    BankTransferReviewRequested event,
    Emitter<BankTransferState> emit,
  ) async {
    final current = state;
    if (current is! BankTransferEditing || !current.canContinue) return;

    // The form validates too, but the bloc must not trust its callers.
    final narration = event.narration.trim();
    if (!BankTransferRules.isAmountWithinLimits(event.amountInNaira) ||
        narration.length > BankTransferRules.maxNarrationLength) {
      return;
    }

    emit(current.copyWith(isQuoting: true, clearError: true));
    try {
      final fee = await _repository.getTransferFee(event.amountInNaira);

      _idempotencyKey = _generateKey();
      emit(
        BankTransferReviewing(
          BankTransferDraft(
            recipient: current.recipient!,
            amountInNaira: event.amountInNaira,
            feeInNaira: fee,
            narration: narration,
          ),
        ),
      );
    } on BankTransferFailure catch (failure) {
      emit(current.copyWith(errorMessage: failure.message));
    }
  }

  void _onEditRequested(
    BankTransferEditRequested event,
    Emitter<BankTransferState> emit,
  ) {
    // Not allowed after an unknown outcome: the previous attempt may have
    // been accepted, and a new one would risk sending the money twice.
    final draft = switch (state) {
      BankTransferReviewing(:final draft) ||
      BankTransferFailed(:final draft) => draft,
      _ => null,
    };
    if (draft == null) return;

    _idempotencyKey = null;
    emit(
      BankTransferEditing(
        banks: _banks,
        selectedBank: draft.recipient.bank,
        accountNumber: draft.recipient.accountNumber,
        lookupStatus: RecipientLookupStatus.resolved,
        recipient: draft.recipient,
      ),
    );
  }

  Future<void> _onConfirmed(
    BankTransferConfirmed event,
    Emitter<BankTransferState> emit,
  ) async {
    final current = state;
    final draft = switch (current) {
      BankTransferReviewing(:final draft) ||
      BankTransferFailed(:final draft) ||
      BankTransferOutcomeUnknown(:final draft) => draft,
      _ => null,
    };
    if (draft == null) return;

    // The fee changed: a retry would fail the same way. The user must review
    // the transfer again.
    if (current is BankTransferFailed &&
        current.code == BankTransferErrorCode.feeChanged) {
      return;
    }

    if (!TransferRules.isValidPin(event.pin)) {
      emit(
        BankTransferFailed(
          draft,
          'Enter your ${TransferRules.pinLength}-digit PIN.',
          BankTransferErrorCode.invalidPin,
        ),
      );
      return;
    }

    final idempotencyKey = _idempotencyKey ??= _generateKey();
    emit(BankTransferSubmitting(draft));

    final BankTransferReceipt receipt;
    try {
      receipt = await _repository.transfer(
        idempotencyKey: idempotencyKey,
        draft: draft,
        pin: event.pin,
      );
    } on BankTransferFailure catch (failure) {
      if (failure.isOutcomeUnknown) {
        // Keep the key: a retry must be recognised as the same transfer.
        emit(BankTransferOutcomeUnknown(draft, failure.message));
      } else {
        // Rejected, so nothing was sent. The next attempt is a new request.
        _idempotencyKey = _generateKey();
        emit(BankTransferFailed(draft, failure.message, failure.code));
      }
      return;
    } catch (error, stackTrace) {
      // A bug. Report it, and never leave the UI stuck on "submitting".
      addError(error, stackTrace);
      emit(
        BankTransferOutcomeUnknown(
          draft,
          BankTransferErrorCode.unexpectedResponse.message,
        ),
      );
      return;
    }

    _idempotencyKey = null;
    switch (receipt.status) {
      case BankTransferStatus.success:
        emit(BankTransferSucceeded(receipt));
      case BankTransferStatus.failed:
        emit(BankTransferUnsuccessful(receipt));
      case BankTransferStatus.pending:
        await _trackPending(receipt, emit);
    }
  }

  /// The transfer was accepted but is still pending at the bank. Ask for its
  /// status a few times; the backend keeps working even if we stop.
  Future<void> _trackPending(
    BankTransferReceipt receipt,
    Emitter<BankTransferState> emit,
  ) async {
    emit(BankTransferProcessing(receipt));

    for (var attempt = 1; attempt <= maxStatusChecks; attempt++) {
      await Future<void>.delayed(statusCheckDelay);
      // The user left the screen: stop checking.
      if (emit.isDone) return;

      try {
        final latest = await _repository.getTransfer(receipt.reference);
        switch (latest.status) {
          case BankTransferStatus.success:
            emit(BankTransferSucceeded(latest));
            return;
          case BankTransferStatus.failed:
            emit(BankTransferUnsuccessful(latest));
            return;
          case BankTransferStatus.pending:
            break; // keep checking
        }
      } on BankTransferFailure {
        // A network blip must not look like a failed transfer. Keep trying.
      } catch (error, stackTrace) {
        addError(error, stackTrace);
      }
    }

    emit(BankTransferPending(receipt));
  }
}
