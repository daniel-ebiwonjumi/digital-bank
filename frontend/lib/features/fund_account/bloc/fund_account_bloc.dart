import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/funding_models.dart';
import '../../data/repositories/fund_account_repository.dart';
import 'fund_account_event.dart';
import 'fund_account_state.dart';

class FundAccountBloc extends Bloc<FundAccountEvent, FundAccountState> {
  FundAccountBloc({
    required FundAccountRepository repository,
    this.maxVerifyAttempts = 5,
    this.verifyRetryDelay = const Duration(seconds: 3),
  })  : assert(maxVerifyAttempts > 0),
        _repository = repository,
        super(const FundAccountInitial()) {
    on<FundingSubmitted>(_onFundingSubmitted);
    on<PaymentWindowClosed>(_onPaymentWindowClosed);
  }

  final FundAccountRepository _repository;

  /// How many times to ask the backend before giving up with "pending".
  final int maxVerifyAttempts;
  final Duration verifyRetryDelay;

  Future<void> _onFundingSubmitted(
    FundingSubmitted event,
    Emitter<FundAccountState> emit,
  ) async {
    // A payment is already in progress: ignore repeat taps.
    if (state is FundAccountInitializing ||
        state is FundAccountAwaitingPayment ||
        state is FundAccountVerifying) {
      return;
    }

    // The form validates too, but the bloc must not trust its callers.
    if (!FundingLimits.isWithinLimits(event.amountInNaira)) {
      emit(const FundAccountFailure('Enter a valid amount.'));
      return;
    }

    emit(const FundAccountInitializing());
    try {
      final session = await _repository.initializeFunding(
        amountInNaira: event.amountInNaira,
        method: event.method,
      );
      emit(FundAccountAwaitingPayment(session));
    } on Failure catch (failure) {
      emit(FundAccountFailure(failure.message));
    }
  }

  Future<void> _onPaymentWindowClosed(
    PaymentWindowClosed event,
    Emitter<FundAccountState> emit,
  ) async {
    final current = state;
    if (current is! FundAccountAwaitingPayment) return;

    final reference = current.session.reference;
    emit(FundAccountVerifying(reference));

    for (var attempt = 1; attempt <= maxVerifyAttempts; attempt++) {
      try {
        final status = await _repository.verifyFunding(reference);
        switch (status.type) {
          case FundingStatusType.success:
            emit(FundAccountSuccess(reference));
            return;
          case FundingStatusType.failed:
            emit(const FundAccountFailure('Payment was not completed.'));
            return;
          case FundingStatusType.pending:
            break; // keep checking
        }
      } on Failure {
        // A network blip must not look like a failed payment: the money may
        // have gone through. Keep trying, and end as pending if it persists.
      }

      if (attempt < maxVerifyAttempts) {
        await Future<void>.delayed(verifyRetryDelay);
        if (emit.isDone) return;
      }
    }

    emit(FundAccountPending(reference));
  }
}