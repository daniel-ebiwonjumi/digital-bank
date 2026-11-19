import 'package:digital_bank/features/auth/bloc/auth_bloc.dart';
import 'package:digital_bank/features/auth/bloc/auth_event.dart';
import 'package:digital_bank/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => LoginViewState();
}

class LoginViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final mobileNumberController = TextEditingController();
  final _passswordController = TextEditingController();
  final bool _obscurePassword = true;

  @override
  void dispose() {
    mobileNumberController.dispose();
    _passswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        mobileNumber: mobileNumberController.text.trim(),
        password: _passswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create a bank account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 40),

                  TextFormField(
                    controller: mobileNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile number or Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your mobile number or email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state){
                      final isLoading = state is AuthLoading; 
                      return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      child: isLoading ? const CircularProgressIndicator(
                        strokeWidth: 2
                      ) : const Text('register'),
                    ),
                  );
  }),

                  const SizedBox(height: 10),

                 
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
