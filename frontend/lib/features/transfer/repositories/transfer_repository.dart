import '../models/transfer_models.dart';

/// Implemented by [TransferRepositoryImpl] (real API) and
/// [MockTransferRepository] (no network). Both throw `TransferFailure`.
abstract interface class TransferRepository {
  /// Finds the same-bank account behind [accountNumber].
  Future<Recipient> resolveRecipient(String accountNumber);

  /// Sends the transfer. Calling it again with the same [idempotencyKey]
  /// must never move the money twice; the backend returns the first result.
  Future<TransferReceipt> transfer({
    required String idempotencyKey,
    required TransferDraft draft,
    required String pin,
  });
}
