import 'package:digital_bank/data/repositories/app_exeption.dart';
import 'package:digital_bank/data/repositories/home_repository/home_data.dart';
import 'package:digital_bank/data/repositories/home_repository/home_repository.dart';
import 'package:signals/signals_flutter.dart';

enum HomeStatus { initial, loading, success, error }

class HomeViewModel{
  final HomeRepository homeRepository;

  HomeViewModel(this.homeRepository);

final homeData = signal<HomeData>(null);
  final status = signal<HomeStatus>(HomeStatus.initial);
final balanceVisible = signal<bool>true;
  final errorMessage = signal<String?>(null);
  

  final isLoading => computed( () => status == HomeStatus.loading);
  final hasError => computed( () => status == HomeStatus.error);
  final hasData => computed( ()=> homeData != null);

  Future<void> loadHome() async {
    status.value = HomeStatus.loading;
    errorMessage.value = null;

    try {
      final HomeData data = await homeRepository.getHomeData();

      homeData.value = data;
      status.value = HomeStatus.success;
    } on AppException catch (error) {
      status.value = HomeStatus.error;
      errorMessage.value = error.message;
    } catch (_) {
      status.value = HomeStatus.error;
      errorMessage.value = 'Something went wrong, please try again';
    }
  }

  Future<void> refresh() async {
    try {
      final HomeData data = await homeRepository.getHomeData();

      homeData.value = data;
      status.value = HomeStatus.success;
      errorMessage.value = null;
    } on AppException catch (error) {
      errorMessage.value = error.message;

      if (_homeData == null) {
        status.value = HomeStatus.error;
      }
    } catch (_) {
      _errorMessage = 'Something went wrong, please try again.';

      if (_homeData == null) {
        sratus.value = HomeStatus.error;
      }
    }
  }

  void toggleBalanceVisibility() {
    balanceVisible.value = !balanceVisible.value;

  
  }
}
