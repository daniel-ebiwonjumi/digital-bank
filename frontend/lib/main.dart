import 'package:digital_bank/core/dio_config.dart';
import 'package:digital_bank/features/auth/auth_bloc.dart';
import 'package:digital_bank/features/auth/auth_event.dart';
import 'package:digital_bank/features/auth/auth_repository.dart';
import 'package:digital_bank/features/auth/auth_service.dart';
import 'package:digital_bank/features/auth/auth_token_storage.dart';
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

  //Home feature

  runApp(
      MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          lazy: false,
          create: (_) =>
              AuthBloc(authRepository)..add(const AuthCheckRequested()),
        ),
      ],

    
      child: 
      const DigitalBank(),
    ),
  ); 

 /* MaterialApp(
    debugShowCheckedModeBanner: false,
     theme: ThemeData(
        useMaterial3: true,
        // Sets the default size for standard Icon widgets across the app
        iconTheme: const IconThemeData(
          size: 40.0, 
          color: Colors.blue,
        ),
         textTheme: const TextTheme(
          // Default style for standard Text('Hello') widgets
          bodyMedium: TextStyle(fontSize: 20.0),
          // Larger body copy
          bodyLarge: TextStyle(fontSize: 18.0),
          // Titles and headings
          titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28.0),
      ),
      navigationBarTheme: NavigationBarThemeData(
      iconTheme:   WidgetStateProperty.all(
      const IconThemeData(size: 40.0),)),),

  
      home: const Dashboard()));
      */
}
