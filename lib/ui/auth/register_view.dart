import 'package:digital_bank/ui/auth/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:social_and_recommendation_system/ui/auth/login_screen.dart';
import 'package:social_and_recommendation_system/ui/homepage/homepage.dart';
import 'auth_widgets.dart';


class RegisterView extends StatefulWidget{
  final AuthViewModel authViewModel;
  const RegisterView({super.key, required authViewModel});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}
class _SignupScreenState extends State<RegisterView> {

final _emailController = TextEditingController();
final _passswordController = TextEditingController();
final _firstNameController = TextEditingController();
final _surnameController = TextEditingController();

bool isLoading = false;

}