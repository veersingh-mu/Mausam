import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_wizard_screen.dart';
import 'screens/settings/persona_settings_screen.dart';
import 'screens/customize/customize_homepage_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MausamApp(),
    ),
  );
}

class MausamApp extends StatelessWidget {
  const MausamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mausam - IMD Weather',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingWizardScreen(),
        '/settings/personas': (context) => const PersonaSettingsScreen(),
        '/customize': (context) => const CustomizeHomepageScreen(),
      },
    );
  }
}
