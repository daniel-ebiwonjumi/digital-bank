import "package:digital_bank/data/services/home_service/home_service.dart";

class HomeRepository {
    final HomeService homeService;
    const HomeRepository(this.homeService);

Future<Home> getHome() async {
    try {
        final response = await homeService.getHome();
    final data = response.data;

    return Home.fromJson(data('home'));
}
catch(_){

}

}

}
