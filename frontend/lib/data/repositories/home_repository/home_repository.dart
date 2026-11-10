import "package:digital_bank/data/services/home_service/home_service.dart";

class HomeRepository {
    final HomeService homeService;
    const HomeRepository(this.homeService);

Future<HomeData> getHome() async {
    try {
        final response = await homeService.getHome();
    final data = response.data;

    return HomeData.fromJson(data('home'));
}
catch(_){

}

}

}
