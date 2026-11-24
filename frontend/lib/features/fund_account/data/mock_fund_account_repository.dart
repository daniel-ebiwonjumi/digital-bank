import '../../../../core/errors/failure.dart';
import '../models/funding_models.dart';
import 'fund_account_repository.dart';

/// A hand-written fake: no network, fully controllable.
/// Use it while the backend does not exist yet, and in tests.
class MockFundAccountRepository implements FundAccountRepository {
  MockFundAccountRepository({
    this.latency = const Duration(milliseconds: 800),
    this.initializeError,
    this.verifyErrorCount = 0,
    this.verifySequence = const [
      FundingStatusType.pending,
      FundingStatusType.pending,
      FundingStatusType.success,
    ],
  }) : assert(verifySequence.isNotEmpty);

  /// Simulated network delay. Use Duration.zero in tests.
  final Duration latency;

  /// If set, initializeFunding throws it.
  final Failure? initializeError;

  /// The first N verifyFunding calls after each initializeFunding throw a
  /// network Failure, to test retry behaviour.
  final int verifyErrorCount;

  /// Status returned by each verifyFunding call (after the errors above), in
  /// order. The last entry repeats once the list runs out.
  final List<FundingStatusType> verifySequence;

  // Recorded so tests can assert what the bloc sent.
  double? lastAmountInNaira;
  FundingMethod? lastMethod;

  int _initializeCalls = 0;
  int _verifyCalls = 0;

  @override
  Future<FundingSession> initializeFunding({
    required double amountInNaira,
    required FundingMethod method,
  }) async {
    await Future<void>.delayed(latency);

    final error = initializeError;
    if (error != null) throw error;

    lastAmountInNaira = amountInNaira;
    lastMethod = method;
    _verifyCalls = 0;
    _initializeCalls++;

    final reference = 'mock_ref_$_initializeCalls';
    return FundingSession(
      // Any https page works: in mock mode, tap the close button in the
      // WebView screen to simulate finishing the payment.
      authorizationUrl: 'https://example.com/?reference=$reference',
      reference: reference,
    );
  }

  @override
  Future<FundingStatus> verifyFunding(String reference) async {
    await Future<void>.delayed(latency);

    final call = _verifyCalls++;
    if (call < verifyErrorCount) {
      throw const Failure(
        'Network problem. Check your connection and try again.',
      );
    }

    final index = call - verifyErrorCount;
    final type = verifySequence[
        index < verifySequence.length ? index : verifySequence.length - 1];

    return FundingStatus(reference: reference, type: type);
  }
}