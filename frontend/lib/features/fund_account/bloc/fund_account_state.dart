l   import 'package:equatable/equatable.dart';

import '../../data/models/funding_models.dart';

sealed class FundAccountState extends Equatable {
  const FundAccountState();

  @override
  List<Object?> get props => [];
}

final class FundAccountInitial extends FundAccountState {
  const FundAccountInitial();
}

/// Calling POST /wallet/fund/initialize.
final class FundAccountInitializing extends FundAccountState {
  const FundAccountInitializing();
}

/// Session created; the UI should open the checkout WebView.
final class FundAccountAwaitingPayment extends FundAccountState {
  const FundAccountAwaitingPayment(this.session);

  final FundingSession session;

  @override
  List<Object?> get props => [session];
}

/// Checking the payment status with the backend.
final class FundAccountVerifying extends FundAccountState {
  const FundAccountVerifying(this.reference);

  final String reference;

  @override
  List<Object?> get props => [reference];
}

final class FundAccountSuccess extends FundAccountState {
  const FundAccountSuccess(this.reference);

  final String reference;

  @override
  List<Object?> get props => [reference];
}

/// Backend has not confirmed yet (common for bank transfers).
/// The balance will update once the webhook lands.
final class FundAccountPending extends FundAccountState {
  const FundAccountPending(this.reference);

  final String reference;

  @override
  List<Object?> get props => [reference];
}

final class FundAccountFailure extends FundAccountState {
  const FundAccountFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}