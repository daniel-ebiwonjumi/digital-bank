import 'package:digital_bank/app/app_router.dart';
import 'package:digital_bank/data/repositories/auth_repository/auth_repository.dart';
import 'package:digital_bank/data/repositories/home_repository/home_repository.dart';
import 'package:digital_bank/data/services/auth_services/auth_service.dart';
import 'package:digital_bank/data/services/auth_services/auth_token_storage.dart';
import 'package:digital_bank/data/services/dio_config.dart';
import 'package:digital_bank/data/services/home_service/home_service.dart';
import 'package:digital_bank/ui/auth/bloc/auth_bloc.dart';
import 'package:digital_bank/ui/auth/bloc/auth_event.dart';

import 'package:digital_bank/ui/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:digital_bank/app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  //Find out later if this is really necessary even if
  //I'm using flutter_secure_storage
  WidgetsFlutterBinding.ensureInitialized();
  //Auth feature
  final authTokenStorage = AuthTokenStorage();
  final dioConfig = DioConfig();
  final authService = AuthService(dioConfig);
  final authRepository = AuthRepository(
    authService: authService,
    authTokenStorage: authTokenStorage,
  );

  final appRouter = AppRouter(
   
  );

  //Home feature
  final homeService = HomeService();
  final homeRepository = HomeRepository(homeService);
  final homeViewModel = HomeViewModel(homeRepository);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          lazy: false,
          create: (_) =>
              AuthBloc(authRepository)..add(const AuthCheckRequested()),
        ),
      ],
      child: const DigitalBank(appRouter: appRouter),
    ),
  );
}
