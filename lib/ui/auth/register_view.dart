import 'package:digital_bank/ui/auth/auth_view_model.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget{
  final AuthViewModel authViewModel;
  const RegisterView({super.key, required this.authViewModel});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}
class _RegisterViewState extends State<RegisterView> {
final _formKey = GlobalKey<FormState>();

final _mobileNumberController = TextEditingController();
final _passswordController = TextEditingController();

bool _loading = false;
bool _obscurePassword = true;

 @override
  void dispose() {
    _mobileNumberController.dispose();
    _passswordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
setState(() {
      _loading = true;
    });
    final success = await widget.authViewModel.login(
      mobileNumberOrEmail: _mobileNumberController.text.trim(),
      password: _passswordController.text,
    );
    if (!mounted) return;

    setState(() => _loading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.authViewModel.error ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get a banking account'),
      ),
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
                    controller: _mobileNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your mobile number';
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
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Get a banking account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}