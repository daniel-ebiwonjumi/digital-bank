import '../models/transfer_failure.dart';
import '../models/transfer_models.dart';
import 'transfer_repository.dart';

/// A hand-written fake: no network, fully controllable.
/// Use it while the backend does not exist yet, and in tests.
///
/// Default test data: accounts 0123456789 (Ada Obi) and 0987654321
/// (Chinedu Okeke), PIN 1234, balance ₦250,000.
class MockTransferRepository implements TransferRepository {
  MockTransferRepository({
    this.latency = const Duration(milliseconds: 600),
    Map<String, String>? recipients,
    this.validPin = '1234',
    this.balanceInNaira = 250000,
    List<TransferFailure>? transferFailures,
  }) : recipients =
           recipients ??
           const {
             '0123456789': 'Ada Obi',
             '0987654321': 'Chinedu Okeke',
           },
       _transferFailures = [...?transferFailures];

  /// Simulated network delay. Use Duration.zero in tests.
  final Duration latency;

  /// Known accounts: account number -> account name.
  final Map<String, String> recipients;

  final String validPin;

  /// Reduced by every successful transfer.
  double balanceInNaira;

  /// Failures thrown by the next transfer calls, one per call, in order,
  /// before anything is processed. Use them to test error and retry paths.
  final List<TransferFailure> _transferFailures;

  // Recorded so tests can assert what the bloc sent.
  final List<String> receivedKeys = [];
  TransferDraft? lastDraft;
  int transfersCreated = 0;

  final Map<String, TransferReceipt> _receiptsByKey = {};

  @override
  Future<Recipient> resolveRecipient(String accountNumber) async {
    await Future<void>.delayed(latency);

    final name = recipients[accountNumber];
    if (name == null) {
      throw TransferFailure(TransferErrorCode.recipientNotFound);
    }
    return Recipient(accountNumber: accountNumber, accountName: name);
  }

  @override
  Future<TransferReceipt> transfer({
    required String idempotencyKey,
    required TransferDraft draft,
    required String pin,
  }) async {
    await Future<void>.delayed(latency);

    receivedKeys.add(idempotencyKey);
    lastDraft = draft;

    if (_transferFailures.isNotEmpty) throw _transferFailures.removeAt(0);

    // Same key, same result: this is what the real backend must do too.
    final existing = _receiptsByKey[idempotencyKey];
    if (existing != null) return existing;

    if (pin != validPin) throw TransferFailure(TransferErrorCode.invalidPin);
    if (draft.amountInNaira > balanceInNaira) {
      throw TransferFailure(TransferErrorCode.insufficientFunds);
    }

    balanceInNaira -= draft.amountInNaira;
    transfersCreated++;

    final receipt = TransferReceipt(
      reference: 'MOCK-${transfersCreated.toString().padLeft(6, '0')}',
      amountInNaira: draft.amountInNaira,
      recipient: draft.recipient,
      narration: draft.narration,
      createdAt: DateTime.now(),
    );
    _receiptsByKey[idempotencyKey] = receipt;
    return receipt;
  }
}
