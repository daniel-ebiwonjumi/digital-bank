import 'package:dio/dio.dart';

import '../models/funding_models.dart';

/// Raw API calls. No error mapping here; the repository does that.
class FundAccountService {
  const FundAccountService(this._dio);

  final Dio _dio;

  /// [amountInNaira] is sent as is; the backend converts it to kobo.
  Future<FundingSession> initialize({
    required double amountInNaira,
    required FundingMethod method,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/wallet/fund/initialize',
      data: {'amount': amountInNaira, 'channel': method.apiValue},
    );
    return FundingSession.fromJson(_bodyOf(response));
  }

  Future<FundingStatus> verify(String reference) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/wallet/fund/verify/${Uri.encodeComponent(reference)}',
    );
    return FundingStatus.fromJson(_bodyOf(response));
  }

  Map<String, dynamic> _bodyOf(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) throw const FormatException('Empty response body');
    return data;
  }
}