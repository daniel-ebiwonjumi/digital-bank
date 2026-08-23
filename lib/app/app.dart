import 'package:digital_bank/ui/auth/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:digital_bank/app/app_routes.dart';

class DigitalBank extends StatefulWidget {
  final AuthViewModel authViewModel;

  const DigitalBank({super.key, required this.authViewModel});

  @override
  State<DigitalBank> createState() => _DigitalBankState();
}

class _DigitalBankState extends State<DigitalBank> {
  late final AppRouter _appRouter;
  @override
  void initState(){
    super.initState();

_appRouter = AppRouter(widget.authViewModel);
    widget.authViewModel.checkAuthentication();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return  MaterialApp.router(
debugShowCheckedModeBanner: false,
title: 'Digital Bank',
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue,),
  useMaterial3: true,),
  routerConfig: _appRouter.router,
  
    );
  }
}
