import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'app_theme.dart';
import 'auth_screen.dart';
import 'user_profile.dart';

void main() {
  runApp(const VitalBandApp());
}

class VitalBandApp extends StatelessWidget {
  const VitalBandApp({super.key});

  static final _navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToShell(UserProfile profile) {
    _navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AppShell(
          profile: profile,
          onSignOut: () {
            _navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => AuthScreen(onAuthenticated: navigateToShell),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vital Band',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: buildAppTheme(),
      home: AuthScreen(
        onAuthenticated: (profile) => navigateToShell(profile),
      ),
    );
  }
}
