import 'package:arsys/features/auth/application/auth_provider.dart';
import 'package:arsys/features/auth/presentation/screens/login_page.dart';
import 'package:arsys/features/staff/pre_defense/presentation/pre_defense_list_page.dart';
import 'package:arsys/features/staff/review/presentation/review_list_page.dart';
import 'package:arsys/features/staff/supervise/presentation/supervise_list_page.dart';
import 'package:arsys/features/staff/final_defense/presentation/final_defense_list_page.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 2; // Default to Home

  static const List<Widget> _pages = [
    SuperviseListPage(),
    ReviewListPage(),
    Center(child: Text('Home Page')),
    PreDefenseListPage(),
    FinalDefenseListPage(),
  ];

  static const List<String> _titles = [
    'Supervised Research',
    'Review',
    'Home',
    'Pre-Defense',
    'Final Defense',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        items: const [
          TabItem(icon: Icons.supervisor_account, title: 'Supervise'),
          TabItem(icon: Icons.checklist, title: 'Review'),
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.article, title: 'Pre'),
          TabItem(icon: Icons.workspace_premium, title: 'Final'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
