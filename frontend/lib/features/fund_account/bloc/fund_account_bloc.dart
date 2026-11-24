class FundAccountBloc estends Bloc<FundAccountEvent, FundAccountState> {
    FundAccountBloc({
        required FundAccountRepository fundAccountRepository
    }) : _fundAccountRepository = FundAccountRepository,
    super(FundAccountInitial()){
        on<FundingSessionSubmitted>(_onFundingSessionSummited),
        on<PaymentWindowClosed>(_onPaymentWindowClosed)
    }

    final FundAccountRepository _fundAccountRepository;

Future<void> _onFundingSessionSummited(
    FundingSessionSubmitted event,
    Emitter<FundAccountState> emit,
) async {
    if(state is FundAccountInitializing) return;
    emit(FundAccountInitializing());
    try(
        final session = FundAccountRepositoryImpl.initializeFunding(
            amount: event.amount,
            method: event.method
        );
        emit(FundAccountAwaitingPayment(session));    
    ) catch(_){}
}

Future<void> _onPaymentWindowClosed(
    FundAccountEvent event,
    Emitter<FundAccountState> state
) async { try { 
    fibal status = await _fundAccountRepositoryImpl.verify(reference);
    switch (status.type){
     case FundingStatusType.success:
     emit(FundAccountSuccess(reference));
     return;
     case FundingStatusType.failure:
     emit(FundAccountFailure(reference));
     break;
    } catch (_){}

    emit(FundAccountPending());
}

}