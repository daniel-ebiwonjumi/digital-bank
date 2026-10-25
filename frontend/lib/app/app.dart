import 'package:digital_bank/ui/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:digital_bank/app/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DigitalBank extends StatefulWidget {
  const DigitalBank({super.key});

  @override
  State<DigitalBank> createState() => _DigitalBankState();
}

class _DigitalBankState extends State<DigitalBank> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();

    final authBloc = context.read<AuthBloc>();
    _appRouter = AppRouter(authBloc);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Digital Bank',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _appRouter.router,
    );
  }
}
