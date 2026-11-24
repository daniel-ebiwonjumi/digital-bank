class FundAccountState extends Equatable {
    const FundAccountState();

@override
    List<Object> get props => [];
}

class FundAccountInitial extends FundAccountState{
    const FundAccountInitial();
}

class FundAccountInitializing extends FundAccountState{
 const FundAccountInitializing();
}

 class FundAccountAwaitingPayment extends FundAccountState {
    const FundAccountAwaitingPayment(thus.session);
    final FundingSession session;
    @override
    List<Object> get props => [session];
 }

 class FundAccountVerifying extends FundAccountState{
    const FundAccountVerifying(this.reference);
    final String reference;
 @override
   List<Object?> get props => [reference];
   }

   
   final class FundAccountPending extends AddMoneyState {
     const FundAccountPending(this.reference);

       final String reference;

         @override
           List<Object?> get props => [reference];
           }

           final class FundAccountFailure extends AddMoneyState {
             const FundAccountFailure(this.message);

               final String message;

                 @override
                   List<Object?> get props => [message];
                   }

 