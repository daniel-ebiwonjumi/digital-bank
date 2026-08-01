import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'login_view_model.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
final _emailController = TextEditingController();
final _passswordController = TextEditingController();
@override
Widget build(BuildContext context){ 
 return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppLogo(),
            CustomTextField(hintText: 'Phone number or Email address', prefixIcon: Icons.email_outlined, controller: _emailController),
            CustomTextField(hintText: 'Password', prefixIcon: Icons.lock_outline, controller: _passswordController),
            Container(
              child: Center(child:
              TextButton(child: Text('If you don\'t have an account: Signup',
            ),
              onPressed:() {
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => const SignupScreen() ));
              }))
            )
                     
          ]
        )
      )
    )
  );
}

}