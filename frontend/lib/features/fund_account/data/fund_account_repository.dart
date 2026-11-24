import '../models/funding_models.dart';

/// Implemented by [FundAccountRepositoryImpl] (real API) and
/// [MockFundAccountRepository] (no network). Both throw `Failure` on errors.
abstract interface class FundAccountRepository {
  /// Starts a funding session for [amountInNaira].
  Future<FundingSession> initializeFunding({
    required double amountInNaira,
    required FundingMethod method,
  });

  /// Asks the backend for the current status of a funding session.
  Future<FundingStatus> verifyFunding(String reference);
}