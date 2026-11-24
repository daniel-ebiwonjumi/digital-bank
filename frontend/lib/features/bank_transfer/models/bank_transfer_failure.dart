import '../../../../core/errors/failure.dart';

enum BankTransferErrorCode {
  // The outcome is UNKNOWN: the transfer may or may not have gone through.
  network(
    'We could not reach the server. Check your connection and try again.',
  ),
  server('Our servers are having a problem. Please try again shortly.'),
  unexpectedResponse('We could not confirm the response from the server.'),

  // The request was rejected: nothing was transferred.
  sessionExpired('Your session has expired. Please log in again.'),
  recipientNotFound(
    'We could not verify this account. Check the bank and account number.',
  ),
  insufficientFunds('Your balance is too low to cover the amount and the fee.'),
  limitExceeded('This amount is above your transfer limit.'),
  invalidPin('Incorrect PIN. Please try again.'),
  pinLocked('Too many incorrect PIN attempts. Please try again later.'),
  rateLimited('Too many attempts. Please wait a moment and try again.'),
  feeChanged('The transfer fee has changed. Please review the transfer again.'),
  serviceUnavailable(
    'Transfers to other banks are temporarily unavailable. '
    'Please try again later.',
  ),
  rejected('We could not process this transfer.');

  const BankTransferErrorCode(this.message);

  /// Default user-facing message. Server messages are not shown, except for
  /// validation errors (see the repository).
  final String message;

  /// True when we cannot tell whether the money moved.
  bool get isOutcomeUnknown =>
      this == network || this == server || this == unexpectedResponse;

  /// Maps the `code` field of the backend's error body.
  static BankTransferErrorCode? fromServerCode(String? code) => switch (code) {
    'INSUFFICIENT_FUNDS' => BankTransferErrorCode.insufficientFunds,
    'INVALID_PIN' => BankTransferErrorCode.invalidPin,
    'PIN_LOCKED' => BankTransferErrorCode.pinLocked,
    'RECIPIENT_NOT_FOUND' => BankTransferErrorCode.recipientNotFound,
    'LIMIT_EXCEEDED' => BankTransferErrorCode.limitExceeded,
    'FEE_CHANGED' => BankTransferErrorCode.feeChanged,
    'TRANSFER_UNAVAILABLE' => BankTransferErrorCode.serviceUnavailable,
    _ => null,
  };
}

class BankTransferFailure extends Failure {
  BankTransferFailure(this.code, {String? message})
    : super(message ?? code.message);

  final BankTransferErrorCode code;

  bool get isOutcomeUnknown => code.isOutcomeUnknown;
}
