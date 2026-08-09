import 'package:flutter/material.dart';
import 'package:social_and_recommendation_system/ui/auth/login_screen.dart';
import 'package:social_and_recommendation_system/ui/homepage/homepage.dart';
import 'auth_widgets.dart';


class SignupScreen extends StatefulWidget{
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}
class _SignupScreenState extends State<SignupScreen> {

final _emailController = TextEditingController();
final _passswordController = TextEditingController();
final _firstNameController = TextEditingController();
final _surnameController = TextEditingController();

bool isLoading = false;



void _handleSignup() async {
  if(_firstNameController.text.isEmpty || _surnameController.text.isEmpty || _passswordController.text.isEmpty || _emailController.text.isEmpty) return;
setState(() {
  isLoading = true;
});
var user = await authRepository.login(_emailController.text, _passswordController.text);


  if (user != null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account created successfully!")));
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email already exists in mock memory.")));
  }
}

@override
Widget build(BuildContext context){ 
 return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppLogo(),
             CustomTextField(hintText: 'First Name', prefixIcon: Icons.person, controller: _firstNameController),
              CustomTextField(hintText: 'Surname', prefixIcon: Icons.person, controller: _surnameController),

            CustomTextField(hintText: 'Phone number or Email address', prefixIcon: Icons.email_outlined, controller: _emailController),
            CustomTextField(hintText: 'Password', prefixIcon: Icons.lock_outline, controller: _passswordController),
             Center(child:
              ElevatedButton(
              onPressed: isLoading ? null: _handleSignup,
              child: isLoading ? const CircularProgressIndicator() : const Text('Sign up'),

              ))
            
                     
          ]
        )
      )
    )
  );
}

}