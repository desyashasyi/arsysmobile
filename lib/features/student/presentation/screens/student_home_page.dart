import 'package:arsys/features/auth/application/auth_provider.dart';
import 'package:arsys/features/auth/presentation/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentHomePage extends ConsumerWidget {
  const StudentHomePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final studentName = user?['name'] ?? 'Student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ArSys Student'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome, $studentName!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
