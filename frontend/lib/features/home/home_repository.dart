import 'package:digital_bank/features/home/home_data.dart';
import 'package:digital_bank/features/home/home_service.dart';

class HomeRepository {
  final HomeService homeService;
  const HomeRepository(this.homeService);

  Future<HomeData> getHomeData() async {
    try {
      final response = await homeService.getHomeData();
      final data = response.data;

      return HomeData.fromJson(data('homeData'));
    } catch (_) {
      throw Exception();
    }
  }
}
