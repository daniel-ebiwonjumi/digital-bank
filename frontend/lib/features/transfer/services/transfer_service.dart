import 'package:dio/dio.dart';

import '../models/transfer_models.dart';

/// Raw API calls. No error mapping here; the repository does that.
///
/// Make sure your Dio logging interceptor never prints request bodies for
/// POST /transfers: they contain the PIN.
class TransferService {
  const TransferService(this._dio);

  final Dio _dio;

  Future<Recipient> resolveRecipient(String accountNumber) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/transfers/recipient/${Uri.encodeComponent(accountNumber)}',
    );
    return Recipient.fromJson(_bodyOf(response));
  }

  /// [draft.amountInNaira] is sent as is; the backend converts it to kobo.
  Future<TransferReceipt> transfer({
    required String idempotencyKey,
    required TransferDraft draft,
    required String pin,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/transfers',
      data: {
        'recipientAccountNumber': draft.recipient.accountNumber,
        'amount': draft.amountInNaira,
        if (draft.narration.isNotEmpty) 'narration': draft.narration,
        'pin': pin,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return TransferReceipt.fromJson(_bodyOf(response));
  }

  Map<String, dynamic> _bodyOf(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) throw const FormatException('Empty response body');
    return data;
  }
}
