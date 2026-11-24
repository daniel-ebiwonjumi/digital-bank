import '../models/bank_transfer_models.dart';

/// Implemented by [BankTransferRepositoryImpl] (real API) and
/// [MockBankTransferRepository] (no network). Both throw
/// `BankTransferFailure`.
abstract interface class BankTransferRepository {
  /// Supported banks, sorted by name.
  Future<List<Bank>> getBanks();

  /// Verifies the account and returns the name it is registered under.
  Future<BankRecipient> resolveRecipient({
    required Bank bank,
    required String accountNumber,
  });

  /// The fee, in naira, for sending [amountInNaira].
  Future<double> getTransferFee(double amountInNaira);

  /// Submits the transfer. Calling it again with the same [idempotencyKey]
  /// must never move the money twice; the backend returns the first result.
  /// A successful call usually returns a receipt with status `pending`.
  Future<BankTransferReceipt> transfer({
    required String idempotencyKey,
    required BankTransferDraft draft,
    required String pin,
  });

  /// The latest status of a transfer that was accepted earlier.
  Future<BankTransferReceipt> getTransfer(String reference);
}
