import 'package:equatable/equatable.dart';

import '../../data/models/transfer_failure.dart';
import '../../data/models/transfer_models.dart';

sealed class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

/// Nothing entered yet, or the account number is incomplete.
final class TransferInitial extends TransferState {
  const TransferInitial();
}

final class TransferLookingUpRecipient extends TransferState {
  const TransferLookingUpRecipient(this.accountNumber);

  final String accountNumber;

  @override
  List<Object?> get props => [accountNumber];
}

final class TransferRecipientLookupFailed extends TransferState {
  const TransferRecipientLookupFailed(this.accountNumber, this.message);

  final String accountNumber;
  final String message;

  @override
  List<Object?> get props => [accountNumber, message];
}

/// Recipient found; the user can enter an amount.
final class TransferRecipientResolved extends TransferState {
  const TransferRecipientResolved(this.recipient);

  final Recipient recipient;

  @override
  List<Object?> get props => [recipient];
}

/// Review step: waiting for the user to confirm with their PIN.
final class TransferReviewing extends TransferState {
  const TransferReviewing(this.draft);

  final TransferDraft draft;

  @override
  List<Object?> get props => [draft];
}

final class TransferSubmitting extends TransferState {
  const TransferSubmitting(this.draft);

  final TransferDraft draft;

  @override
  List<Object?> get props => [draft];
}

final class TransferSucceeded extends TransferState {
  const TransferSucceeded(this.receipt);

  final TransferReceipt receipt;

  @override
  List<Object?> get props => [receipt];
}

/// The backend rejected the transfer: nothing was sent. The user can fix the
/// problem (for example re-enter the PIN) and try again.
final class TransferFailed extends TransferState {
  const TransferFailed(this.draft, this.message, this.code);

  final TransferDraft draft;
  final String message;
  final TransferErrorCode code;

  @override
  List<Object?> get props => [draft, message, code];
}

/// We cannot tell whether the transfer went through (timeout, server error,
/// unreadable response). Retrying is safe because it reuses the same
/// idempotency key. Starting a new transfer is not.
final class TransferOutcomeUnknown extends TransferState {
  const TransferOutcomeUnknown(this.draft, this.message);

  final TransferDraft draft;
  final String message;

  @override
  List<Object?> get props => [draft, message];
}
