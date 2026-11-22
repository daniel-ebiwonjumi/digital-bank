import 'package:digital_bank/features/fund_account/models/fund_account.dart';
import 'package:equatable/equatable.dart';

sealed class FundAccountEvent extends Equatable {
  const FundAccountEvent();

  List<Object> get props => [];
}

final class FundingSessionSubmitted extends FundAccountEvent {
  FundingSessionSubmitted({required this.amount, required this.method});

  final int amount;
  final FundingMethod method;


  List<Object> get props => [amount, method];
}

final class PaymentWindowClosed extends FundAccountEvent {
  const PaymentWindowClosed();
}
