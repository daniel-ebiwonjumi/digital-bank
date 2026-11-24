import 'package:equatable/equatable.dart';

// Sealed subclasses must live in the same file as the sealed class
// (no `part of` needed; the bloc simply imports this file).
sealed class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

/// The account number field changed. A lookup starts at 10 digits.
final class RecipientAccountNumberChanged extends TransferEvent {
  const RecipientAccountNumberChanged(this.accountNumber);

  final String accountNumber;

  @override
  List<Object?> get props => [accountNumber];
}

/// User tapped Continue on the form.
final class TransferReviewRequested extends TransferEvent {
  const TransferReviewRequested({
    required this.amountInNaira,
    required this.narration,
  });

  final double amountInNaira;
  final String narration;

  @override
  List<Object?> get props => [amountInNaira, narration];
}

/// User went back from the review step to change the details.
final class TransferEditRequested extends TransferEvent {
  const TransferEditRequested();
}

/// User entered their PIN to confirm the transfer.
final class TransferConfirmed extends TransferEvent {
  const TransferConfirmed(this.pin);

  final String pin;

  // The PIN must never appear in equality checks or logs (BlocObserver
  // prints events).
  @override
  List<Object?> get props => [];

  @override
  String toString() => 'TransferConfirmed(pin: ***)';
}
