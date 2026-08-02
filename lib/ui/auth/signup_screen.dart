import 'package:flutter/material.dart';
import 'package:social_and_recommendation_system/ui/homepage/homepage.dart';
import 'auth_widgets.dart';
import 'login_view_model.dart';

class SignupScreen extends StatefulWidget{
  const SignupScreen({super.key});

  @override

  State<SignupScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<SignupScreen> {
final _emailController = TextEditingController();
final _passswordController = TextEditingController();
final _firstNameController = TextEditingController();
final _surnameController = TextEditingController();
final _professionController = TextEditingController();
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
               CustomTextField(hintText: 'Profession', prefixIcon: Icons.book, controller: _professionController),
            CustomTextField(hintText: 'Phone number or Email address', prefixIcon: Icons.email_outlined, controller: _emailController),
            CustomTextField(hintText: 'Password', prefixIcon: Icons.lock_outline, controller: _passswordController),
             Center(child:
              ElevatedButton(child: Text('Signup',
            ),
              onPressed:() {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Homepage(),));
              }))
            
                     
          ]
        )
      )
    )
  );
}

}