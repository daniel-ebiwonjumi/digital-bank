import 'package:digital_bank/features/fund_account/data/fund_account_repository.dart';
import 'package:digital_bank/features/fund_account/fund_account_service.dart';
import 'package:digital_bank/features/fund_account/models/fund_account.dart';

class FundAccountRepositoryImpl implements FundAccountRepository {
  const FundAccountRepositoryImpl({required this.fundAccountService});

  final FundAccountService fundAccountService;
  @override
  Future<FundingSession?> initializeFunding({
    required int amount,
    required FundingMethod method,
  }) async {
    return await fundAccountService.initializeFunding(
      amount: amount,
      method: method,
    );
  }

  @override
  Future<FundingStatus?> verify({required String reference}) {
    // TODO: implement verify
    return fundAccountService.verify(reference: reference);
  }
}
