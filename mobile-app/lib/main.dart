import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'app_theme.dart';
import 'auth_screen.dart';

void main() {
  runApp(const VitalBandApp());
}

class VitalBandApp extends StatelessWidget {
  const VitalBandApp({super.key});

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vital Band',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: buildAppTheme(),
      home: AuthScreen(
        onAuthenticated: (profile) {
          // Replace sign-in after authentication so Back doesn't reopen it.
          _navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute<void>(builder: (_) => AppShell(profile: profile)),
          );
        },
      ),
    );
  }
}
