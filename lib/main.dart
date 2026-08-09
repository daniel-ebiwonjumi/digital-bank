import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_and_recommendation_system/data/repositories/auth_repository_impl.dart';
import 'package:social_and_recommendation_system/ui/auth/login_screen.dart';


void main(){
  runApp(const FullApp());
}

class FullApp extends StatelessWidget{
  const FullApp({super.key});

  @override
  Widget build(BuildContext context){
    return  MaterialApp(
      title: 'Full App',
      home: LoginScreen(),
      theme: ThemeData(
      
      ),
    );
  }
}