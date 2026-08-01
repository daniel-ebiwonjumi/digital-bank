import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        )
      ),
    );
  }
}