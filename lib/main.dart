import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/api_config.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/manager_home_screen.dart';

void main() {
  ApiConfig.setEnvironment(Environment.production);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static const _gold = Color(0xFFB39123);
  static const _navy = Color(0xFF252B5A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final baseTextTheme = GoogleFonts.ralewayTextTheme();

    return MaterialApp(
      title: 'CSLV Manager',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7490)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: baseTextTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _navy,
          indicatorColor: Colors.transparent,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return IconThemeData(color: isSelected ? _gold : Colors.white);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return GoogleFonts.raleway(
              color: isSelected ? _gold : Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
      ),
      home: Builder(
        builder: (context) {
          if (!authState.isInitialized || authState.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!authState.isAuthenticated) {
            return const LoginScreen();
          }

          return const ManagerHomeScreen();
        },
      ),
    );
  }
}
