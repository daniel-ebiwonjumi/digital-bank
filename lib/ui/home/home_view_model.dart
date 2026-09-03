import 'package:digital_bank/data/repositories/app_exeption.dart';
import 'package:digital_bank/data/repositories/home_repository/home_data.dart';
import 'package:digital_bank/data/repositories/home_repository/home_repository.dart';
import 'package:flutter/foundation.dart';

enum HomeStatus { initial, loading, success, error }

class HomeViewModel{
  final HomeRepository homeRepository;

  HomeViewModel(this.homeRepository);

final HomeData? _homeData;
HomeData get homeData => _homeData;
  final status = signal<HomeStatus>(HomeStatus.initial);
final balanceVisible = signal<bool>true;
  final errorMessage = signal<String?>(null);
  

  final isLoading => compute( () => status == HomeStatus.loading);
  final hasError => compute( () => status == HomeStatus.error);
  final hasData => compute( ()=> homeData != null);

  Future<void> loadHome() async {
    status.value = HomeStatus.loading;
    errorMessage.value = null;

    try {
      final HomeData data = await homeRepository.getHomeData();

      _homeData = data;
      _status = HomeStatus.success;
    } on AppException catch (error) {
      _status = HomeStatus.error;
      _errorMessage = error.message;
    } catch (_) {
      _status = HomeStatus.error;
      _errorMessage = 'Something went wrong, please try again';
    }
  }

  Future<void> refresh() async {
    try {
      final HomeData data = await homeRepository.getHomeData();

      _homeData = data;
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
