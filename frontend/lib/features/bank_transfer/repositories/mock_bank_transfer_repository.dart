import '../models/bank_transfer_failure.dart';
import '../models/bank_transfer_models.dart';
import 'bank_transfer_repository.dart';

/// A hand-written fake: no network, fully controllable.
/// Use it while the backend does not exist yet, and in tests.
///
/// Default test data: Access Bank 0123456789 (Ada Obi), GTBank 0987654321
/// (Chinedu Okeke), PIN 1234, balance ₦250,000, fee ₦26.88. Transfers are
/// accepted as pending and settle after [pendingChecks] status checks.
class MockBankTransferRepository implements BankTransferRepository {
  MockBankTransferRepository({
    this.latency = const Duration(milliseconds: 600),
    this.banks = defaultBanks,
    Map<String, String>? accounts,
    this.feeInNaira = 26.88,
    this.validPin = '1234',
    this.balanceInNaira = 250000,
    this.initialStatus = BankTransferStatus.pending,
    this.pendingChecks = 1,
    this.finalStatus = BankTransferStatus.success,
    this.banksFailure,
    this.feeFailure,
    List<BankTransferFailure>? transferFailures,
  }) : accounts =
           accounts ??
           const {
             '044:0123456789': 'Ada Obi',
             '058:0987654321': 'Chinedu Okeke',
           },
       _transferFailures = [...?transferFailures];

  static const List<Bank> defaultBanks = [
    Bank(code: '044', name: 'Access Bank'),
    Bank(code: '011', name: 'First Bank of Nigeria'),
    Bank(code: '214', name: 'First City Monument Bank'),
    Bank(code: '058', name: 'Guaranty Trust Bank'),
    Bank(code: '50211', name: 'Kuda Microfinance Bank'),
    Bank(code: '033', name: 'United Bank for Africa'),
    Bank(code: '057', name: 'Zenith Bank'),
  ];

  /// Simulated network delay. Use Duration.zero in tests.
  final Duration latency;

  final List<Bank> banks;

  /// Known accounts: '<bankCode>:<accountNumber>' -> account name.
  final Map<String, String> accounts;

  final double feeInNaira;
  final String validPin;

  /// Reduced by every transfer, restored if the transfer ends up failed.
  double balanceInNaira;

  /// Status of a transfer when it is accepted.
  final BankTransferStatus initialStatus;

  /// How many status checks return `pending` before [finalStatus] appears.
  final int pendingChecks;

  /// The status a pending transfer settles to. Use `pending` to simulate a
  /// transfer that never settles.
  final BankTransferStatus finalStatus;

  /// If set, getBanks / getTransferFee throw it.
  final BankTransferFailure? banksFailure;
  final BankTransferFailure? feeFailure;

  /// Failures thrown by the next transfer calls, one per call, in order,
  /// before anything is processed. Use them to test error and retry paths.
  final List<BankTransferFailure> _transferFailures;

  // Recorded so tests can assert what the bloc sent.
  final List<String> receivedKeys = [];
  BankTransferDraft? lastDraft;
  int transfersCreated = 0;

  final Map<String, BankTransferReceipt> _receiptsByKey = {};
  final Map<String, BankTransferReceipt> _receiptsByReference = {};
  final Map<String, int> _statusChecks = {};
  final Set<String> _refunded = {};

  Future<void> _pause() => Future<void>.delayed(latency);

  @override
  Future<List<Bank>> getBanks() async {
    await _pause();
    final failure = banksFailure;
    if (failure != null) throw failure;
    return banks;
  }

  @override
  Future<BankRecipient> resolveRecipient({
    required Bank bank,
    required String accountNumber,
  }) async {
    await _pause();

    final name = accounts['${bank.code}:$accountNumber'];
    if (name == null) {
      throw BankTransferFailure(BankTransferErrorCode.recipientNotFound);
    }
    return BankRecipient(
      bank: bank,
      accountNumber: accountNumber,
      accountName: name,
    );
  }

  @override
  Future<double> getTransferFee(double amountInNaira) async {
    await _pause();
    final failure = feeFailure;
    if (failure != null) throw failure;
    return feeInNaira;
  }

  @override
  Future<BankTransferReceipt> transfer({
    required String idempotencyKey,
    required BankTransferDraft draft,
    required String pin,
  }) async {
    await _pause();

    receivedKeys.add(idempotencyKey);
    lastDraft = draft;

    if (_transferFailures.isNotEmpty) throw _transferFailures.removeAt(0);

    // Same key, same result: this is what the real backend must do too.
    final existing = _receiptsByKey[idempotencyKey];
    if (existing != null) return existing;

    if (pin != validPin) {
      throw BankTransferFailure(BankTransferErrorCode.invalidPin);
    }
    if ((draft.feeInNaira - feeInNaira).abs() > 0.005) {
      throw BankTransferFailure(BankTransferErrorCode.feeChanged);
    }
    if (draft.totalInNaira > balanceInNaira) {
      throw BankTransferFailure(BankTransferErrorCode.insufficientFunds);
    }

    balanceInNaira -= draft.totalInNaira;
    transfersCreated++;

    final receipt = BankTransferReceipt(
      reference: 'MOCK-BT-${transfersCreated.toString().padLeft(6, '0')}',
      status: initialStatus,
      amountInNaira: draft.amountInNaira,
      feeInNaira: draft.feeInNaira,
      recipient: draft.recipient,
      narration: draft.narration,
      createdAt: DateTime.now(),
    );
    _receiptsByKey[idempotencyKey] = receipt;
    _receiptsByReference[receipt.reference] = receipt;
    return receipt;
  }

  @override
  Future<BankTransferReceipt> getTransfer(String reference) async {
    await _pause();

    final receipt = _receiptsByReference[reference];
    if (receipt == null) {
      throw BankTransferFailure(BankTransferErrorCode.rejected);
    }

    final checks = _statusChecks[reference] =
        (_statusChecks[reference] ?? 0) + 1;
    if (checks <= pendingChecks || finalStatus == BankTransferStatus.pending) {
      return receipt;
    }

    if (finalStatus == BankTransferStatus.failed && _refunded.add(reference)) {
      balanceInNaira += receipt.totalInNaira;
    }
    return receipt.copyWith(status: finalStatus);
  }
}
