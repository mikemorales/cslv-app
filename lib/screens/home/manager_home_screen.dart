import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
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
  static const _navy = Color(0xFF252B5A);
  static const _gold = Color(0xFFB39123);

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
    final connectivity = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: Text(
          _titles[_currentIndex],
          style: GoogleFonts.notoSerif(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  user.name,
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            color: _gold,
          ),
        ],
      ),
      body: Column(
        children: [
          connectivity.when(
            data: (isOnline) => isOnline
                ? const SizedBox.shrink()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    color: Colors.orange.shade700,
                    child: const Text(
                      'Offline mode: showing cached data when available.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, stackTrace) => const SizedBox.shrink(),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_work), label: 'Villas'),
          NavigationDestination(icon: Icon(Icons.article), label: 'Posts'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Admins'),
          NavigationDestination(icon: Icon(Icons.payments), label: 'Payments'),
        ],
      ),
    );
  }
}
