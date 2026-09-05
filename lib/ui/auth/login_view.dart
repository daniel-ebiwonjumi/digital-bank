import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_bank/ui/auth/auth_view_model.dart';
import 'package:digital_bank/app/app_router.dart';
import 'package:signals/signals_flutter.dart';

class LoginView extends StatefulWidget {
  final AuthViewModel authViewModel;

  const LoginView(this.authViewModel);

  @override
  State<LoginView> createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final _mobileNumberOrEmailController = TextEditingController();
  final _passswordController = TextEditingController();

  @override
  void dispose() {
    _mobileNumberOrEmailController.dispose();
    _passswordController.dispose();


    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
  
    final success = await widget.authViewModel.login(
      mobileNumberOrEmail: _mobileNumberOrEmailController.text.trim(),
      password: _passswordController.text,
    );
    if (!mounted) return;
    if (!success) { ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.authViewModel.error ?? 'Login failed')),
      );
    }
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
                    'Welcome to the modern bank',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _mobileNumberOrEmailController,
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

                  SignalBuilder (builder: (context) => TextFormField(
                    controller: _passswordController,
                    obscureText: _obscurePassword.value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureLoginPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {                     authViewModel.obscureLoginPassword.value = !authViewModel.obscurePassword.value;
                 
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  )),

                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: SignalBuilder(builder: (context) => ElevatedButton(
                      onPressed: authViewModel?.isLoading.value ? null : _login,
                      child: authViewModel.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Login'),
                    )),
                  ),

                  const SizedBox(height: 10),

                  SignalBuilder (builder: (context) => TextButton(
                    onPressed: authViewModel.isLoading.value
                        ? null
                        : () => context.goNamed(AppRoutes.register),

                    child: const Text('Don\'t have an account? Get an account'),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
