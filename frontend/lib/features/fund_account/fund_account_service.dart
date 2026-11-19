import 'package:digital_bank/core/api_config.dart';
import 'package:digital_bank/core/dio_config.dart';
import 'package:digital_bank/features/fund_account/models/fund_account.dart';


class FundAccountService {
  FundAccountService({required this.dioConfig});

  final DioConfig dioConfig;

  Future<FundingSession?> initializeFunding({
    required int amount,
    required FundingMethod method,
  }) async {
    final response = await dioConfig.dio.post<Map<String, dynamic>>(
      ApiConfig.initializeFunding,
      data: {'amount': amount, 'channel': method.apiValue},
    );
    final data = response.data;
    if (data == null) return null;
    return FundingSession.fronJson(data);
  }

  Future<FundingStatus?> verify({required String reference}) async {
    final response = await dioConfig.dio.get<Map<String, dynamic>>(
      '/wallet/fund/verify/${Uri.encodeComponent(reference)}',
    );
    final data = response.data;
    if (data == null) return null;
    return FundingStatus.fronJson(data);
  }
}
