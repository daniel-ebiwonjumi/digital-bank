import 'package:digital_bank/data/repositories/app_exeption.dart';
import 'package:digital_bank/data/repositories/home_repository/home_data.dart';
import 'package:digital_bank/data/repositories/home_repository/home_repository.dart';
import 'package:flutter/foundation.dart';

enum HomeStatus { initial, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;

  HomeViewModel(this.homeRepository);

  HomeStatus _status = HomeStatus.initial;
  HomeData? _homeData;
  String? _errorMessage;
  bool _balanceVisible = true;

  HomeStatus get status => _status;
  HomeData? get homeData => _homeData;
  String? get errorMessage => _errorMessage;
  bool get balanceVisible => _balanceVisible;
  bool get isLoading => _status == HomeStatus.loading;
  bool get hasError => _status == HomeStatus.error;
  bool get hasData => _homeData != null;

  Future<void> loadHome() async {
    _status = HomeStatus.loading;
    _errorMessage = null;

    notifyListeners();

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

    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      final HomeData data = await homeRepository.getHomeData();

      _homeData = data;
      _status = HomeStatus.success;
      _errorMessage = null;
    } on AppException catch (error) {
      _errorMessage = error.message;

      if (_homeData == null) {
        _status = HomeStatus.error;
      }
    } catch (_) {
      _errorMessage = 'Something went wrong, please try again.';

      if (_homeData == null) {
        _status = HomeStatus.error;
      }
    }
  }

  void toggleBalanceVisibility() {
    _balanceVisible = !_balanceVisible;

    notifyListeners();
  }
}
