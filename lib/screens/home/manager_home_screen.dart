import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../administrators/administrators_list_screen.dart';
import '../payments/payments_list_screen.dart';
import '../posts/posts_list_screen.dart';
import '../villas/villas_list_screen.dart';

class ManagerHomeScreen extends ConsumerStatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  ConsumerState<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends ConsumerState<ManagerHomeScreen> {
  int _currentIndex = 0;

  static const _titles = [
    'Villas',
    'Posts',
    'Administrators',
    'Pending Payments',
  ];

  static const _screens = [
    VillasListScreen(),
    PostsListScreen(),
    AdministratorsListScreen(),
    PaymentsListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text(user.name)),
            ),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_work), label: 'Villas'),
          NavigationDestination(icon: Icon(Icons.article), label: 'Posts'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Admins'),
          NavigationDestination(
            icon: Icon(Icons.payments),
            label: 'Payments',
          ),
        ],
      ),
    );
  }
}
