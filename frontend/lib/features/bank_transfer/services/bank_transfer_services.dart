import 'package:dio/dio.dart';

import '../models/bank_transfer_models.dart';

/// Raw API calls. No error mapping here; the repository does that.
///
/// Make sure your Dio logging interceptor never prints request bodies for
/// POST /bank-transfers: they contain the PIN.
class BankTransferService {
  const BankTransferService(this._dio);

  final Dio _dio;

  Future<List<Bank>> getBanks() async {
    final response = await _dio.get<Map<String, dynamic>>('/banks');
    final list = _bodyOf(response)['banks'];
    if (list is! List) throw const FormatException('Invalid bank list');

    final banks = <Bank>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final bank = Bank.tryFromJson(item);
        if (bank != null) banks.add(bank);
      }
    }
    if (banks.isEmpty) throw const FormatException('Empty bank list');
    return banks;
  }

  Future<BankRecipient> resolveAccount({
    required Bank bank,
    required String accountNumber,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/bank-transfers/resolve',
      queryParameters: {'bankCode': bank.code, 'accountNumber': accountNumber},
    );
    final body = _bodyOf(response);
    final number = body['accountNumber'];
    final name = body['accountName'];

    if (number is! String || name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid account');
    }
    return BankRecipient(
      bank: bank,
      accountNumber: number,
      accountName: name.trim(),
    );
  }

  /// The fee for sending [amountInNaira], in naira.
  Future<double> getFee(double amountInNaira) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/bank-transfers/fee',
      queryParameters: {'amount': amountInNaira},
    );
    final fee = _bodyOf(response)['fee'];
    if (fee is! num || !fee.isFinite || fee < 0) {
      throw const FormatException('Invalid fee');
    }
    return fee.toDouble();
  }

  /// Amounts are sent in naira; the backend converts to kobo.
  /// `expectedFee` lets the backend reject the request if the fee changed
  /// since the user reviewed it.
  Future<BankTransferReceipt> transfer({
    required String idempotencyKey,
    required BankTransferDraft draft,
    required String pin,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/bank-transfers',
      data: {
        'bankCode': draft.recipient.bank.code,
        'accountNumber': draft.recipient.accountNumber,
        'amount': draft.amountInNaira,
        'expectedFee': draft.feeInNaira,
        if (draft.narration.isNotEmpty) 'narration': draft.narration,
        'pin': pin,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return BankTransferReceipt.fromJson(_bodyOf(response));
  }

  Future<BankTransferReceipt> getTransfer(String reference) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/bank-transfers/${Uri.encodeComponent(reference)}',
    );
    return BankTransferReceipt.fromJson(_bodyOf(response));
  }

  Map<String, dynamic> _bodyOf(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) throw const FormatException('Empty response body');
    return data;
  }
}
