import 'package:equatable/equatable.dart';

import '../../data/models/funding_models.dart';

// Sealed subclasses must live in the same file as the sealed class
// (no `part of` needed; the bloc simply imports this file).
sealed class FundAccountEvent extends Equatable {
  const FundAccountEvent();

  @override
  List<Object?> get props => [];
}

/// User tapped Continue with a valid amount (in naira) and a chosen method.
final class FundingSubmitted extends FundAccountEvent {
  const FundingSubmitted({required this.amountInNaira, required this.method});

  final double amountInNaira;
  final FundingMethod method;

  @override
  List<Object?> get props => [amountInNaira, method];
}

/// The checkout WebView was closed (callback reached or user left).
/// Says nothing about success; the bloc must verify with the backend.
final class PaymentWindowClosed extends FundAccountEvent {
  const PaymentWindowClosed();
}