import 'package:flutter/material.dart';
import 'package:social_and_recommendation_system/app/app_routes.dart';

class FullApp extends StatelessWidget{
  const FullApp({super.key});

  @override
  Widget build(BuildContext context){
    return  MaterialApp.router(
      routerConfig: router,
      title: 'Full App',
      theme: ThemeData(
      
      ),
    );
  }
}