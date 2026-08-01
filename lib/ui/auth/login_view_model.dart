import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier{
    final emailController = TextEditingController();
  final passswordController = TextEditingController();

  void login(){
final email = emailController.text.trim();
final password = passswordController.text;

debugPrint('authenticating user $email ');
  }
  @override
  void dispose(){
    emailController.dispose();
    passswordController.dispose();
    super.dispose();
  }


}