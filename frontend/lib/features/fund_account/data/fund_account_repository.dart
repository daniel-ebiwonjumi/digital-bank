import 'package:digital_bank/features/fund_account/models/fund_account.dart';

abstract interface class FundAccountRepository {
Future<FundingSession?> initializeFunding({
  required int amount,
  required FundingMethod method
});

Future<FundingStatus?> verify({required String reference});
}
