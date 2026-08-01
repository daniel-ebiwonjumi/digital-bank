import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget{
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context){
return Padding(
  padding: EdgeInsets.symmetric(vertical: 40),
  child: Center(child: Icon(
    Icons.flutter_dash, //TODO: use image.asset to add my own customized logo here later
  size: 80,
  color: Theme.of(context).colorScheme.primary
  ),)
);
  }

}

class CustomTextField extends StatelessWidget{
const CustomTextField({super.key, required this.hintText, required this.prefixIcon, this.isPassword = false, required this.controller, this.validator});
final String hintText;
final IconData prefixIcon;
final bool isPassword;
final TextEditingController controller;
final String? Function(String?)? validator;

@override
Widget build(BuildContext context){
  return TextField(
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
    ),
    obscureText: isPassword,
    controller: controller,

  );
}
}