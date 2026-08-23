import 'package:digital_bank/data/repositories/auth_repostory.dart';
import 'package:digital_bank/data/services/auth_services/auth_service.dart';
import 'package:digital_bank/data/services/auth_services/auth_token_storage.dart';
import 'package:digital_bank/ui/auth/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:digital_bank/app/app.dart';


void main(){
  WidgetsFlutterBinding.ensureInitialized();
  final authTokenStorage = AuthTokenStorage();
  final api = Api(authTokenStorage);
  final authService  = AuthService(api);
  final authRepository = AuthRepository(authService: authService, authTokenStorage: authTokenStorage);
  final authViewModel = AuthViewModel(authRepository);

  runApp( DigitalBank(
    authViewModel: authViewModel,
  ));
}

