import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/idempotency_key.dart';
import '../../data/models/transfer_failure.dart';
import '../../data/models/transfer_models.dart';
import '../../data/repositories/transfer_repository.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc({
    required TransferRepository repository,
    String Function() idempotencyKeyGenerator = generateIdempotencyKey,
  }) : _repository = repository,
       _generateKey = idempotencyKeyGenerator,
       super(const TransferInitial()) {
    // A newer account number cancels the lookup in flight, so a slow, stale
    // response can never overwrite a newer one.
    on<RecipientAccountNumberChanged>(
      _onAccountNumberChanged,
      transformer: restartable(),
    );
    on<TransferReviewRequested>(_onReviewRequested);
    on<TransferEditRequested>(_onEditRequested);
    // Extra taps while a transfer is in flight are dropped.
    on<TransferConfirmed>(_onConfirmed, transformer: droppable());
  }

  final TransferRepository _repository;
  final String Function() _generateKey;

  /// Identifies one transfer attempt. It is created when the review step
  /// opens, kept when the outcome is unknown (so a retry cannot duplicate the
  /// transfer) and replaced after a definite failure or when editing.
  String? _idempotencyKey;

  bool get _isEditingRecipient => switch (state) {
    TransferInitial() ||
    TransferLookingUpRecipient() ||
    TransferRecipientLookupFailed() ||
    TransferRecipientResolved() => true,
    _ => false,
  };

  Future<void> _onAccountNumberChanged(
    RecipientAccountNumberChanged event,
    Emitter<TransferState> emit,
  ) async {
    if (!_isEditingRecipient) return;

    final accountNumber = event.accountNumber.trim();
    if (!TransferRules.isValidAccountNumber(accountNumber)) {
      if (state is! TransferInitial) emit(const TransferInitial());
      return;
    }

    emit(TransferLookingUpRecipient(accountNumber));
    try {
      final recipient = await _repository.resolveRecipient(accountNumber);
      emit(TransferRecipientResolved(recipient));
    } on TransferFailure catch (failure) {
      emit(TransferRecipientLookupFailed(accountNumber, failure.message));
    }
  }

  void _onReviewRequested(
    TransferReviewRequested event,
    Emitter<TransferState> emit,
  ) {
    final current = state;
    if (current is! TransferRecipientResolved) return;

    // The form validates too, but the bloc must not trust its callers.
    final narration = event.narration.trim();
    if (!TransferRules.isAmountWithinLimits(event.amountInNaira) ||
        narration.length > TransferRules.maxNarrationLength) {
      return;
    }

    _idempotencyKey = _generateKey();
    emit(
      TransferReviewing(
        TransferDraft(
          recipient: current.recipient,
          amountInNaira: event.amountInNaira,
          narration: narration,
        ),
      ),
    );
  }

  void _onEditRequested(
    TransferEditRequested event,
    Emitter<TransferState> emit,
  ) {
    // Not allowed after an unknown outcome: the previous attempt may have
    // succeeded, and a new one would risk sending the money twice.
    final draft = switch (state) {
      TransferReviewing(:final draft) || TransferFailed(:final draft) => draft,
      _ => null,
    };
    if (draft == null) return;

    _idempotencyKey = null;
    emit(TransferRecipientResolved(draft.recipient));
  }

  Future<void> _onConfirmed(
    TransferConfirmed event,
    Emitter<TransferState> emit,
  ) async {
    final draft = switch (state) {
      TransferReviewing(:final draft) ||
      TransferFailed(:final draft) ||
      TransferOutcomeUnknown(:final draft) => draft,
      _ => null,
    };
    if (draft == null) return;

    if (!TransferRules.isValidPin(event.pin)) {
      emit(
        TransferFailed(
          draft,
          'Enter your ${TransferRules.pinLength}-digit PIN.',
          TransferErrorCode.invalidPin,
        ),
      );
      return;
    }

    final idempotencyKey = _idempotencyKey ??= _generateKey();
    emit(TransferSubmitting(draft));

    try {
      final receipt = await _repository.transfer(
        idempotencyKey: idempotencyKey,
        draft: draft,
        pin: event.pin,
      );
      _idempotencyKey = null;
      emit(TransferSucceeded(receipt));
    } on TransferFailure catch (failure) {
      if (failure.isOutcomeUnknown) {
        // Keep the key: a retry must be recognised as the same transfer.
        emit(TransferOutcomeUnknown(draft, failure.message));
      } else {
        // Rejected, so nothing was sent. The next attempt is a new request.
        _idempotencyKey = _generateKey();
        emit(TransferFailed(draft, failure.message, failure.code));
      }
    } catch (error, stackTrace) {
      // A bug. Report it, and never leave the UI stuck on "submitting".
      addError(error, stackTrace);
      emit(
        TransferOutcomeUnknown(
          draft,
          TransferErrorCode.unexpectedResponse.message,
        ),
      );
    }
  }
}
