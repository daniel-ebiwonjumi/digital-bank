import 'package:equatable/equatable.dart';

import '../../data/models/bank_transfer_models.dart';

// Sealed subclasses must live in the same file as the sealed class
// (no `part of` needed; the bloc simply imports this file).
sealed class BankTransferEvent extends Equatable {
  const BankTransferEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the list of banks.
final class BanksRequested extends BankTransferEvent {
  const BanksRequested();
}

/// The bank or the account number changed. Both are handled together so a
/// newer change cancels a lookup that is still in flight.
sealed class RecipientInputEvent extends BankTransferEvent {
  const RecipientInputEvent();
}

final class BankSelected extends RecipientInputEvent {
  const BankSelected(this.bank);

  final Bank bank;

  @override
  List<Object?> get props => [bank];
}

final class AccountNumberChanged extends RecipientInputEvent {
  const AccountNumberChanged(this.accountNumber);

  final String accountNumber;

  @override
  List<Object?> get props => [accountNumber];
}

/// User tapped Continue on the form. The bloc fetches the fee next.
final class BankTransferReviewRequested extends BankTransferEvent {
  const BankTransferReviewRequested({
    required this.amountInNaira,
    required this.narration,
  });

  final double amountInNaira;
  final String narration;

  @override
  List<Object?> get props => [amountInNaira, narration];
}

/// User went back from the review step to change the details.
final class BankTransferEditRequested extends BankTransferEvent {
  const BankTransferEditRequested();
}

/// User entered their PIN to confirm the transfer.
final class BankTransferConfirmed extends BankTransferEvent {
  const BankTransferConfirmed(this.pin);

  final String pin;

  // The PIN must never appear in equality checks or logs (BlocObserver
  // prints events).
  @override
  List<Object?> get props => [];

  @override
  String toString() => 'BankTransferConfirmed(pin: ***)';
}
