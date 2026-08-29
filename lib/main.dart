import 'package:digital_bank/data/repositories/auth_repository/auth_repostory.dart';
import 'package:digital_bank/data/repositories/home_repository/home_repository.dart';
import 'package:digital_bank/data/services/auth_services/auth_service.dart';
import 'package:digital_bank/data/services/auth_services/auth_token_storage.dart';
import 'package:digital_bank/data/services/home_service/home_service.dart';
import 'package:digital_bank/ui/auth/auth_view_model.dart';
import 'package:digital_bank/ui/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:digital_bank/app/app.dart';

void main() {
  //Find out later if this is really necessary even if
  //I'm using flutter_secure_storage
  WidgetsFlutterBinding.ensureInitialized();
  //Auth feature
  final authTokenStorage = AuthTokenStorage();
  final api = Api(authTokenStorage);
  final authService = AuthService(api);
  final authRepository = AuthRepository(
    authService: authService,
    authTokenStorage: authTokenStorage,
  );
  final authViewModel = AuthViewModel(authRepository);

  //Home feature
  final homeService = HomeService();
  final homeRepository = HomeRepository(homeService);
  final homeViewModel = HomeViewModel(homeRepository);
  runApp(DigitalBank(authViewModel: authViewModel));
}
