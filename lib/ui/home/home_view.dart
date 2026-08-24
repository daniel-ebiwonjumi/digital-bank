import 'package:flutter/material.dart';
import 'package:digital_bank/ui/auth/auth_view_model.dart';

class HomeView extends StatelessWidget {
  final AuthViewModel authViewModel;

  const HomeView({super.key, required this.authViewModel});

  @override
  Widget build(BuildContext context) {
    final user = authViewModel.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await authViewModel.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome ${user?.name ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(user?.email ?? ''),

            ElevatedButton(
              onPressed: () async {
                await authViewModel.logout();
              },
              child: const Text('logout'),
            ),
          ],
        ),
      ),
    );
  }
}
